module LifeStylesHelper

  def checked_living_with(id)
    current_active_profile&.life_style&.living_with&.nil? ? false : current_active_profile&.life_style&.living_with&.include?(id.to_s)
  end

  def checked_dress_style(id)
    current_active_profile&.life_style&.living_with&.nil? ? false : current_active_profile&.life_style&.dress_style&.include?(id.to_s)
  end

end
