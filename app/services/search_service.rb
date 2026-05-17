class SearchService
  def self.with_params(params, current_profile_id)
    search_params = [:age_from, :age_to, :religion, :hometown, :height,
                     :marital_status, :blood_group, :highest_education_level, :occupation]
    return MarriageProfile.none unless search_params.any? { |p| Array(params[p]).reject(&:blank?).present? }

    @matches = MarriageProfile.all
    @marriage_profile = MarriageProfile.find_by(id: current_profile_id)

    if @marriage_profile
      @matches = @matches.where.not(id: current_profile_id, gender: @marriage_profile.gender)
      @matches = @matches.where.not(id: @marriage_profile.friend_ids)
      @matches = @matches.where.not(id: @marriage_profile.favourite_profile_ids)
      @matches = @matches.where.not(id: @marriage_profile.pending_friend_ids)
      @matches = @matches.where.not(id: @marriage_profile.requested_friend_ids)
    end

    # Age range
    age_from = params[:age_from].to_i if params[:age_from].present?
    age_to   = params[:age_to].to_i   if params[:age_to].present?
    if age_from && age_to
      @matches = @matches.where('EXTRACT(YEAR FROM age(cast(date_of_birth as date))) BETWEEN ? AND ?', age_from, age_to)
    elsif age_from
      @matches = @matches.where('EXTRACT(YEAR FROM age(cast(date_of_birth as date))) >= ?', age_from)
    elsif age_to
      @matches = @matches.where('EXTRACT(YEAR FROM age(cast(date_of_birth as date))) <= ?', age_to)
    end

    # Religion
    if params[:religion].present?
      @matches = @matches.where("religion IN (?)", MarriageProfile.religions["#{params[:religion].downcase}"])
    end

    # Hometown
    if params[:hometown].present?
      @matches = @matches.where("hometown IN (?)", params[:hometown])
      if params[:hometown] == 'Outside Bangladesh'
        if params[:hometown_country].present?
          @matches = @matches.where("hometown_country ILIKE ?", "%#{params[:hometown_country]}%")
        end
        if params[:hometown_city].present?
          @matches = @matches.where("hometown_city ILIKE ?", "%#{params[:hometown_city]}%")
        end
      end
    end

    # Advanced Search
    if @marriage_profile&.user&.advanced_search == "enabled"

      # Height (individual)
      heights = Array(params[:height]).reject(&:blank?)
      if heights.present?
        conditions = heights.map do |h|
          parts = h.split('-')
          "(height_ft = #{parts[0].to_i} AND height_inch = #{parts[1].to_i})"
        end
        @matches = @matches.where(conditions.join(" OR "))
      end

      # Marital status (multi)
      marital = Array(params[:marital_status]).reject(&:blank?)
      @matches = @matches.where(marital_status: marital) if marital.present?

      # Blood group (multi)
      blood = Array(params[:blood_group]).reject(&:blank?)
      @matches = @matches.where(blood_group: blood) if blood.present?

      # Education (multi)
      education = Array(params[:highest_education_level]).reject(&:blank?)
      @matches = @matches.where(highest_education_level: education) if education.present?

      # Occupation (multi)
      occupations = Array(params[:occupation]).reject(&:blank?)
      if occupations.present?
        @matches = @matches.joins(:occupations).where(occupations: { name: occupations })
      end
    end

    @matches.paginate(page: params[:page], per_page: 12)
  end
end
