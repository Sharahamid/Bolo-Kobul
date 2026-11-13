class RecommendationService
  DAILY_CACHE_EXPIRY = 24.hours
  MIN_RECOMMENDATIONS = 10
  # BK+ perk: twice as many recommendations each day
  BK_PLUS_RECOMMENDATIONS = 20
  # Years the age range may stretch when there are not enough members inside it
  AGE_STRETCH = 2
  HIGH_MATCH_THRESHOLD = 75

  def self.with_preference(current_profile, max_level=5, matched_ids=[])
    return [] unless current_profile
    filtered_profile_ids = build_excluded_ids(current_profile, matched_ids)
    @matches = MarriageProfile.where.not(id: filtered_profile_ids)
    @matches = apply_age_gender_filter(@matches, current_profile)
    preference = current_profile.partner_preference
    apply_filters(@matches, preference, max_level)
    @matches.order(Arel.sql("RANDOM()")).last(MIN_RECOMMENDATIONS - matched_ids.count)
  end

  def self.daily_recommendations(current_profile)
    return [] unless current_profile
    key = cache_key(current_profile)
    cached_ids = Rails.cache.read(key)
    if cached_ids.present?
      # Same order as when the list was made
      found = MarriageProfile.where(id: cached_ids).includes(:user, :partner_preference, :occupations, :cultural_value).index_by(&:id)
      return cached_ids.map { |id| found[id] }.compact
    end

    recommendations = build_recommendations(current_profile)
    Rails.cache.write(key, recommendations.map(&:id), expires_in: DAILY_CACHE_EXPIRY)
    recommendations
  end

  def self.daily_count(profile)
    profile.user&.bk_plus? ? BK_PLUS_RECOMMENDATIONS : MIN_RECOMMENDATIONS
  end

  # Recalculated daily, and also as soon as a new member joins, this member changes their
  # preferences, or BK+ starts or ends (20 instead of 10)
  def self.cache_key(profile)
    "recommendations_v4_#{profile.id}_#{Date.today}_#{MarriageProfile.maximum(:id)}_" \
      "#{profile.partner_preference&.updated_at.to_i}_n#{daily_count(profile)}"
  end

  def self.build_recommendations(current_profile)
    excluded_ids = build_excluded_ids(current_profile, [])
    all_candidates = MarriageProfile.where.not(id: excluded_ids)
                                    .includes(:user, :partner_preference, :occupations, :cultural_value)
    all_candidates = apply_age_gender_filter(all_candidates, current_profile)
    preference = current_profile.partner_preference
    taste = Taste.new(current_profile)
    seen = seen_counts(current_profile)

    # Always include 75%+ matches first
    high_matches = []
    candidates = apply_filters(all_candidates.dup, preference, 5)
    candidates.each do |profile|
      profile.calculate_matching_percentage!(current_profile)
      high_matches << profile if profile.matching_percentage.to_i >= HIGH_MATCH_THRESHOLD
    end
    high_matches = rank(high_matches, taste, seen)

    # Fill remaining slots with the best matches, relaxing the preferences step by step
    wanted = daily_count(current_profile)
    remaining_count = [wanted - high_matches.count, 0].max
    high_match_ids = high_matches.map(&:id)

    other_profiles = []
    preference_level = 5
    while other_profiles.count < remaining_count && preference_level >= 0
      pool = apply_filters(all_candidates.where.not(id: high_match_ids + other_profiles.map(&:id)), preference, preference_level).to_a
      pool.each { |profile| profile.calculate_matching_percentage!(current_profile) }
      other_profiles += rank(pool, taste, seen).first(remaining_count - other_profiles.count)
      preference_level -= 1
    end

    picked = (high_matches + other_profiles).first(wanted)
    remember_seen(current_profile, seen, picked)
    picked
  end

  # Order: match % (in 5-point bands, so small differences don't decide everything),
  # then BK+ members first, then likeness to profiles the member has favourited or sent Kobuls to, then
  # profiles the member has been shown on fewer days, then photo / verified / new /
  # recently active. Anything still equal is shuffled, so the list varies day to day.
  def self.rank(profiles, taste, seen)
    profiles.shuffle.sort_by do |p|
      [-(p.matching_percentage.to_i / 5), p.user&.bk_plus? ? 0 : 1, -taste.score(p), seen[p.id].to_i, -p.match_quality]
    end
  end

  # How many days each profile has already appeared in this member's recommendations
  # (last two weeks)
  def self.seen_counts(profile)
    Rails.cache.read("rec_seen_#{profile.id}") || {}
  rescue StandardError
    {}
  end

  def self.remember_seen(profile, seen, picked)
    updated = seen.dup
    picked.each { |p| updated[p.id] = updated[p.id].to_i + 1 }
    Rails.cache.write("rec_seen_#{profile.id}", updated, expires_in: 14.days)
  rescue StandardError
    nil
  end

  # What a member seems drawn to, learnt from the profiles they favourited, sent a
  # Kobul to or connected with. Needs at least MIN_SIGNALS of them to say anything.
  class Taste
    MIN_SIGNALS = 3

    def initialize(member)
      ids = (member.favourite_profile_ids + member.pending_friend_ids + member.friend_ids +
             member.chat_friendships.map(&:chat_friend_id)).uniq
      liked = ids.size >= MIN_SIGNALS ? MarriageProfile.where(id: ids).includes(:occupations).to_a : []
      @total = liked.size
      @counts = {
        occupation: liked.map(&:matching_occupation).compact.tally,
        education: liked.map(&:highest_education_level).compact.tally,
        location: liked.map(&:present_location).compact.tally,
        hometown: liked.map(&:hometown).compact.tally
      }
    rescue StandardError
      @total = 0
    end

    # 0 (nothing in common, or not enough to go on) up to 4
    def score(profile)
      return 0 if @total.to_i < MIN_SIGNALS

      values = { occupation: profile.matching_occupation, education: profile.highest_education_level,
                 location: profile.present_location, hometown: profile.hometown }
      (values.sum { |key, value| value.nil? ? 0.0 : @counts[key][value].to_f / @total } * 10).round
    end
  end

  def self.build_excluded_ids(current_profile, matched_ids)
    [current_profile.id] +
      matched_ids +
      User.deactivated_users_profile_ids +
      current_profile.user.marriage_profile_ids +
      current_profile.pending_friend_ids +
      current_profile.requested_friend_ids +
      current_profile.friend_ids +
      current_profile.blocked_friend_ids +
      current_profile.chat_friendships.map(&:chat_friend_id) +
      ProfilePass.hidden_ids_for(current_profile) +
      ProfileHide.hidden_ids_for(current_profile) +
      Friendship.where('(friendable_id = ? OR friend_id = ?) AND status = ?', current_profile.id, current_profile.id, 1)
                .map { |f| f.friendable_id == current_profile.id ? f.friend_id : f.friendable_id }
  end

  def self.marital_status_compatible?(seeker, candidate)
    seeker_pref = seeker.partner_preference
    candidate_pref = candidate.partner_preference

    # Step 1: candidate's marital status must be in seeker's preference (or seeker has no preference)
    if seeker_pref&.marital_status.present?
      seeker_accepts_candidate = seeker_pref.marital_status.to_a.map(&:to_s).include?(candidate.marital_status.to_s)
      return false unless seeker_accepts_candidate
    end

    # Step 2: seeker's marital status must be in candidate's preference (or candidate has no preference = open to all)
    if candidate_pref&.marital_status.present?
      candidate_accepts_seeker = candidate_pref.marital_status.to_a.map(&:to_s).include?(seeker.marital_status.to_s)
      return false unless candidate_accepts_seeker
    end

    true
  end

  # No separate bride/groom age rule: age is judged only by the member's own age range
  # (in their preferences and the match %)
  def self.apply_age_gender_filter(matches, _current_profile)
    matches
  end

  def self.apply_filters(matches, preference, max_level)
    return matches unless preference

    matches = matches.where(gender: preference.gender) if preference.gender.present?

    if preference.religion.present?
      matches = matches.where("religion IN (?)", preference.religion.map { |k, v| MarriageProfile.religions[k] })
    end

    if preference.marital_status.present?
      matches = matches.where("marital_status IN (?)", preference.marital_status.map { |k, v| MarriageProfile.marital_statuses[k] })
    end

    if preference.hometown.present? && preference.hometown.length != 1 && max_level >= 4
      matches = matches.where("hometown IN (?)", preference.hometown)
    end

    if preference.present_location.present? && preference.present_location.length != 1 && max_level >= 4
      matches = matches.where("present_location IN (?)", preference.present_location)
    end

    # Age range; when the member left both ages blank, the suggested range (see MarriageProfile#default_age_range)
    min_age = preference.min_age.presence&.to_i
    max_age = preference.max_age.presence&.to_i
    if min_age.nil? && max_age.nil? && (range = preference.marriage_profile&.default_age_range)
      min_age, max_age = range
    end

    # Age range. Strict at first; when the list is still short it may stretch 2 years
    # either side, but a woman is never shown men younger than herself and a man is never
    # shown women older than himself.
    if max_level <= 3 && (min_age || max_age)
      seeker = preference.marriage_profile
      own_age = seeker&.age_in_years
      if min_age
        min_age -= AGE_STRETCH
        min_age = [min_age, [own_age, min_age + AGE_STRETCH].min].max if own_age && seeker.female?
      end
      if max_age
        max_age += AGE_STRETCH
        max_age = [max_age, [own_age, max_age - AGE_STRETCH].max].min if own_age && seeker.male?
      end
    end

    if min_age
      matches = matches.where('date_of_birth <= ?', Date.current.years_ago(min_age).end_of_day)
    end

    if max_age
      matches = matches.where('date_of_birth > ?', Date.current.years_ago(max_age + 1).end_of_day)
    end

    if preference.min_height.present? && max_level >= 2
      matches = matches.where('(height_ft = ? AND height_inch >= ?) OR (height_ft > ?)', preference.min_height, preference.min_inch.to_i, preference.min_height)
    end

    if preference.max_height.present? && max_level >= 5
      matches = matches.where('(height_ft = ? AND height_inch <= ?) OR (height_ft < ?)', preference.max_height, preference.max_inch.to_i, preference.max_height)
    end

    if preference.physical_status.present? && !preference.ps_does_not_matter? && max_level >= 5
      matches = matches.joins(:appearance).where('appearances.physical_status = ?', PartnerPreference.physical_statuses[preference.physical_status])
    end

    if preference.family_status.present? && !preference.fs_does_not_matter? && max_level >= 5
      matches = matches.where(family_status: preference.family_status)
    end

    if preference.family_values.present? && !preference.fv_does_not_matter? && max_level >= 5
      matches = matches.where(family_values: preference.family_values)
    end

    if preference.family_type.present? && !preference.does_not_matter? && max_level >= 5
      matches = matches.where(family_type: preference.family_type)
    end

    if preference.blood_group.present? && max_level >= 5
      matches = matches.where(blood_group: preference.blood_group)
    end

    matches
  end
end
