class SearchService
  # TODO: Fix an easy searching algorithm

  def self.with_params(params, current_profile_id)
    @matches = MarriageProfile.all
    @marriage_profile = MarriageProfile.find_by(id: current_profile_id)

    # Filter out already found ones & same gender ones
    if @marriage_profile
      @matches = @matches.where.not(id: current_profile_id,
                                    gender: @marriage_profile.gender)
      @matches = @matches.where.not(id: @marriage_profile.friend_ids)
      @matches = @matches.where.not(id: @marriage_profile.favourite_profile_ids)
      @matches = @matches.where.not(id: @marriage_profile.pending_friend_ids)
      @matches = @matches.where.not(id: @marriage_profile.requested_friend_ids)
    end

    # Basic Search
    if params[:religion].present?
      @matches = @matches.where(
        "religion IN (?)",
        MarriageProfile.religions["#{params[:religion].downcase}"]
      )
    end
    if params[:hometown].present?
      @matches = @matches.where(
        "hometown IN (?)",
        params[:hometown]
      )
    end
    if params[:age].present?
      @matches = @matches.where('EXTRACT(
                                YEAR FROM
                                age(cast(date_of_birth as date))) = ?',
                                params[:age].to_i)
    end

    # Advanced Search
    if @marriage_profile.user.advanced_search == "enabled"
      if params[:height].present?
        case params[:height]
        when "tier_1"
          @matches = @matches.where(height_ft: 5, height_inch: 1..4)
        when "tier_2"
          @matches = @matches.where(height_ft: 5, height_inch: 5..8)
        when "tier_3"
          @matches = @matches.where('(height_ft IN (?) AND height_inch IN (?))
                                  OR (height_ft IN (?) AND height_inch IN (?))',
                                    5, 9, 6, 0
          )
        when "tier_4"
          @matches = @matches.where(height_ft: 6, height_inch: 1..5)
        end
      end

      if params[:marital_status].present?
        @matches = @matches.where(marital_status: params[:marital_status])
      end

      if params[:blood_group].present?
        @matches = @matches.where(blood_group: params[:blood_group])
      end

      if params[:highest_education_level].present?
        @matches = @matches.where(highest_education_level:
                                    params[:highest_education_level])
      end

      if params[:occupation].present?
        @matches = @matches.joins(:occupations)
                     .where(occupations: {name: params[:occupation]})
      end
    end

    @matches
      .paginate(page: params[:page], per_page: 10)
  end
end
