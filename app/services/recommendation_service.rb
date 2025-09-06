class RecommendationService
  def self.with_preference(current_profile, max_level=5, matched_ids=[])
    return [] unless current_profile

    # Filter out mandatory conditions
    filtered_profile_ids = [current_profile.id] +
      matched_ids +
      User.deactivated_users_profile_ids +
      current_profile.user.marriage_profile_ids +
      current_profile.user.marriage_profile_ids +
      current_profile.favourite_profile_ids +
      current_profile.pending_friend_ids +
      current_profile.requested_friend_ids +
      current_profile.friend_ids +
      current_profile.blocked_friend_ids

    @matches = MarriageProfile.where.not(id: filtered_profile_ids)

    preference = current_profile.partner_preference

    # Gender filtering # level 0
    @matches = @matches.where(gender: preference.gender)

    # Religion filtering # level 0
    if preference.religion.present?
      @matches = @matches.where(
          "religion IN (?)",
          preference.religion.map { |k, v| MarriageProfile.religions[k] },
      )
    end

    # Marital status filtering # level 3
    if preference.marital_status.present? && max_level >= 3
      @matches = @matches.where(
          "marital_status IN (?)",
          preference.marital_status.map { |k, v| MarriageProfile.marital_statuses[k] },
      )
    end

    # Hometown filtering # level 4
    if preference.hometown.present? && preference.hometown.length != 1 && max_level >= 4
      @matches = @matches.where(
          "hometown IN (?)",
          preference.hometown
      )
    end

    # Present location filtering # level 4
    if preference.present_location.present? && preference.present_location.length != 1 && max_level >= 4
      @matches = @matches.where(
          "present_location IN (?)",
          preference.present_location
      )
    end

    # Age filtering # level 1
    if preference.min_age.present? && max_level >= 1
      @matches = @matches
                     .where('extract(year from date_of_birth) <= ?', Time.now.year - preference.min_age.to_i)
    end
    if preference.max_age.present?
      @matches = @matches
                     .where('extract(year from date_of_birth) >= ?', Time.now.year - preference.max_age.to_i)
    end

    # Height and Inch filtering # level 2, 5
    if preference.min_height.present? && max_level >= 2 # level 2
      @matches = @matches
                     .where('(height_ft = ? AND height_inch >= ?) OR (height_ft > ?)', preference.min_height, preference.min_inch, preference.min_height)
    end
    if preference.max_height.present? && max_level >= 5 # level 5
      @matches = @matches
                     .where('height_ft <= ? AND height_inch >= ?', preference.max_height, preference.max_inch)
    end

    # Physical status filtering  # level 5
    if preference.physical_status.present? && !preference.ps_does_not_matter? && max_level >= 5
      @matches = @matches.joins(:appearance)
                         .where('appearances.physical_status = ?',
                                PartnerPreference.physical_statuses[preference.physical_status])
    end

    # Family status filtering # level 5
    if preference.family_status.present? && !preference.fs_does_not_matter? && max_level >= 5
      @matches = @matches.where(family_status: preference.family_status)
    end

    # Family Values filtering # level 5
    if preference.family_values.present? && !preference.fv_does_not_matter? && max_level >= 5
      @matches = @matches.where(family_values: preference.family_values)
    end

    # Family Types filtering # level 5
    if preference.family_type.present? && !preference.does_not_matter? && max_level >= 5
      @matches = @matches.where(family_type: preference.family_type)
    end

    # Blood Group filtering # level 5
    if preference.blood_group.present? && max_level >= 5
      @matches = @matches.where(blood_group: preference.blood_group)
    end

    # Highest Education Level # level 3

    @matches.order("RANDOM()").last(10-matched_ids.count)
  end
end
