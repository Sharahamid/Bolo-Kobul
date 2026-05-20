class RecommendationService
  DAILY_CACHE_EXPIRY = 24.hours
  MIN_RECOMMENDATIONS = 10
  HIGH_MATCH_THRESHOLD = 75

  def self.with_preference(current_profile, max_level=5, matched_ids=[])
    return [] unless current_profile
    filtered_profile_ids = build_excluded_ids(current_profile, matched_ids)
    @matches = MarriageProfile.where.not(id: filtered_profile_ids)
    @matches = apply_age_gender_filter(@matches, current_profile)
    preference = current_profile.partner_preference
    apply_filters(@matches, preference, max_level)
    @matches.order("RANDOM()").last(MIN_RECOMMENDATIONS - matched_ids.count)
  end

  def self.daily_recommendations(current_profile)
    return [] unless current_profile
    cache_key = "recommendations_#{current_profile.id}_#{Date.today}"
    cached_ids = Rails.cache.read(cache_key)
    if cached_ids.present?
      return MarriageProfile.where(id: cached_ids)
    end

    recommendations = build_recommendations(current_profile)
    Rails.cache.write(cache_key, recommendations.map(&:id), expires_in: DAILY_CACHE_EXPIRY)
    recommendations
  end

  def self.build_recommendations(current_profile)
    excluded_ids = build_excluded_ids(current_profile, [])
    all_candidates = MarriageProfile.where.not(id: excluded_ids)
    all_candidates = apply_age_gender_filter(all_candidates, current_profile)
    preference = current_profile.partner_preference

    # Always include 75%+ matches first
    high_matches = []
    candidates = apply_filters(all_candidates.dup, preference, 5)
    candidates.each do |profile|
      profile.calculate_matching_percentage!(current_profile)
      high_matches << profile if profile.matching_percentage.to_i >= HIGH_MATCH_THRESHOLD
    end
    high_matches.sort_by! { |p| -p.matching_percentage }

    # Fill remaining slots with daily shuffled profiles
    remaining_count = [MIN_RECOMMENDATIONS - high_matches.count, 0].max
    high_match_ids = high_matches.map(&:id)

    daily_seed = Date.today.to_s.gsub('-', '').to_i
    other_profiles = []
    preference_level = 5
    while other_profiles.count < remaining_count && preference_level >= 0
      pool = apply_filters(all_candidates.where.not(id: high_match_ids + other_profiles.map(&:id)), preference, preference_level)
      pool = pool.order("RANDOM()").limit(remaining_count - other_profiles.count)
      other_profiles += pool.to_a
      preference_level -= 1
    end

    (high_matches + other_profiles).first(MIN_RECOMMENDATIONS)
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
      Friendship.where('(friendable_id = ? OR friend_id = ?) AND status = ?', current_profile.id, current_profile.id, 1)
                .map { |f| f.friendable_id == current_profile.id ? f.friend_id : f.friendable_id }
  end

  def self.marital_status_compatible?(seeker, candidate)
    seeker_pref = seeker.partner_preference
    candidate_pref = candidate.partner_preference

    # Step 1: candidate's marital status must be in seeker's preference (or seeker has no preference)
    if seeker_pref&.marital_status.present?
      seeker_accepts_candidate = seeker_pref.marital_status.keys.map(&:to_s).include?(candidate.marital_status.to_s)
      return false unless seeker_accepts_candidate
    end

    # Step 2: seeker's marital status must be in candidate's preference (or candidate has no preference = open to all)
    if candidate_pref&.marital_status.present?
      candidate_accepts_seeker = candidate_pref.marital_status.keys.map(&:to_s).include?(seeker.marital_status.to_s)
      return false unless candidate_accepts_seeker
    end

    true
  end

  def self.apply_age_gender_filter(matches, current_profile)
    return matches unless current_profile.date_of_birth.present?
    if current_profile.male?
      # Bride must not be older than groom — bride dob must be >= groom dob
      matches = matches.where("gender = 1 AND date_of_birth >= ?", current_profile.date_of_birth)
                       .or(matches.where("gender != 1"))
    elsif current_profile.female?
      # Groom must not be younger than bride — groom dob must be <= bride dob
      matches = matches.where("gender = 0 AND date_of_birth <= ?", current_profile.date_of_birth)
                       .or(matches.where("gender != 0"))
    end
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

    if preference.min_age.present? && max_level >= 3
      buffer = max_level >= 4 ? 0 : 2
      matches = matches.where('extract(year from date_of_birth) <= ?', Time.now.year - preference.min_age.to_i + buffer)
    end

    if preference.max_age.present? && max_level >= 3
      buffer = max_level >= 4 ? 0 : 2
      matches = matches.where('extract(year from date_of_birth) >= ?', Time.now.year - preference.max_age.to_i - buffer)
    end

    if preference.min_height.present? && max_level >= 2
      matches = matches.where('(height_ft = ? AND height_inch >= ?) OR (height_ft > ?)', preference.min_height, preference.min_inch, preference.min_height)
    end

    if preference.max_height.present? && max_level >= 5
      matches = matches.where('height_ft <= ? AND height_inch >= ?', preference.max_height, preference.max_inch)
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
