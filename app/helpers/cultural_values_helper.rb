module CulturalValuesHelper
  def checked_languages_spoken(id)
    current_active_profile&.cultural_value&.languages_spoken&.nil? ? false : current_active_profile&.cultural_value&.languages_spoken&.include?(id.to_s)
  end
end
