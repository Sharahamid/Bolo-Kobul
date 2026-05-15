module MarriageProfilesHelper

  def get_recommended_profiles
    return [] unless current_active_profile
    profiles = RecommendationService.daily_recommendations(current_active_profile)
    excluded_ids = current_active_profile.pending_friend_ids +
                   current_active_profile.friend_ids +
                   current_active_profile.requested_friend_ids +
                   current_active_profile.blocked_friend_ids +
                   current_active_profile.chat_friendships.map(&:chat_friend_id) +
                   Friendship.where(friend_id: current_active_profile.id, status: 1).map(&:friendable_id) +
                   Friendship.where(friendable_id: current_active_profile.id, status: 1).map(&:friend_id)
    profiles = profiles.reject { |p| excluded_ids.include?(p.id) }
    profiles.each { |profile| profile.calculate_matching_percentage!(current_active_profile) }
    profiles.sort_by { |profile| -profile.matching_percentage.to_i }
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
    current_active_profile.chat_rooms
  end

end
