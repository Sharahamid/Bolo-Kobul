module MarriageProfilesHelper

  def get_recommended_profiles
    preference_level = 5
    recommended_profiles = []
    while recommended_profiles.count < 10 && preference_level > 0
      recommended_profiles += RecommendationService.with_preference(
        current_active_profile,
        preference_level,
        recommended_profiles.map(&:id)
      ).to_a
      preference_level -= 1
    end

    recommended_profiles = recommended_profiles.each { |profile| profile.calculate_matching_percentage! current_active_profile }
    recommended_profiles.sort_by{|profile| -profile.matching_percentage}
  end

  def get_accepted_profiles
    accepted_profiles = MarriageProfile.accepted_profiles(current_active_profile)
  end

  def get_requested_profiles
    requested_profiles = MarriageProfile.requested_profiles(current_active_profile)
  end

  def get_pending_profiles
    pending_profiles = current_active_profile.pending_friends
  end

  def chat_channels
    current_active_profile.chat_rooms
  end

end
