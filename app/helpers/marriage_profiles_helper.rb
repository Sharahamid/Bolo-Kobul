module MarriageProfilesHelper

  def get_recommended_profiles
    return [] unless current_active_profile
    profiles = RecommendationService.daily_recommendations(current_active_profile)
    excluded_ids = current_active_profile.pending_friend_ids +
                   current_active_profile.friend_ids +
                   current_active_profile.requested_friend_ids +
                   current_active_profile.blocked_friend_ids +
                   ProfileHide.hidden_ids_for(current_active_profile) +
                   current_active_profile.chat_friendships.map(&:chat_friend_id) +
                   Friendship.where(friend_id: current_active_profile.id, status: 1).map(&:friendable_id) +
                   Friendship.where(friendable_id: current_active_profile.id, status: 1).map(&:friend_id)
    profiles = profiles.reject { |p| excluded_ids.include?(p.id) }
    profiles.each { |profile| profile.calculate_matching_percentage!(current_active_profile) }
    # Keep the day's order (it already weighs taste and freshness) within each 5-point band
    profiles.each_with_index.sort_by { |profile, i| [-(profile.matching_percentage.to_i / 5), i] }.map(&:first)
  end

  def get_accepted_profiles
    MarriageProfile.accepted_profiles(current_active_profile)
  end

  def get_requested_profiles
    MarriageProfile.requested_profiles(current_active_profile)
  end

  def get_pending_profiles
    current_active_profile.pending_friends
  end

  def chat_channels
    current_active_profile.active_chat_rooms
  end


  # Match % between the signed-in member and another profile, for profile pages,
  # Kobul lists, favourites and chats (worked out once per page)
  def match_percent(profile)
    return nil if profile.nil? || current_active_profile.nil? || profile.id == current_active_profile.id

    @bk_match_percent ||= {}
    @bk_match_percent[profile.id] ||= profile.calculate_matching_percentage!(current_active_profile).to_i
  rescue StandardError
    nil
  end

  # Make sure a profile has its match details worked out for the signed-in member
  def ensure_match_details(profile)
    return if profile.nil? || current_active_profile.nil? || profile.id == current_active_profile.id
    return if profile.instance_variable_defined?(:@match_fit)

    profile.calculate_matching_percentage!(current_active_profile)
  rescue StandardError
    nil
  end

  def mutual_match?(profile)
    ensure_match_details(profile)
    profile&.mutual_match ? true : false
  end

  # "Why this match": the most important things that fit, and what doesn't quite
  # Returns [good_items, [[item, how], ...]] - how is :near, :unknown or :no
  def match_reasons(profile)
    ensure_match_details(profile)
    fit = profile&.match_fit
    return [[], []] if fit.blank?

    order = MarriageProfile::MATCH_WEIGHTS.keys
    sorted = fit.sort_by { |item, _| order.index(item) || 99 }
    good = sorted.select { |_, f| f >= 1.0 }.map(&:first).first(4)
    miss = sorted.reject { |_, f| f >= 1.0 }.map do |item, f|
      [item, f.zero? ? :no : (f >= 0.5 ? :near : :unknown)]
    end.first(2)
    [good, miss]
  end
end
