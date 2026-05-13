module MarriageProfilesHelper

  def get_recommended_profiles
    return [] unless current_active_profile
    profiles = RecommendationService.daily_recommendations(current_active_profile)
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
