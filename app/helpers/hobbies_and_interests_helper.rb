module HobbiesAndInterestsHelper
  def checked_hobby(id)
    current_active_profile&.hobbies_and_interest&.hobby&.nil? ? false : current_active_profile&.hobbies_and_interest&.hobby&.include?(id.to_s)
  end

  def checked_interest(id)
    current_active_profile&.hobbies_and_interest&.interest.nil? ? false : current_active_profile&.hobbies_and_interest&.interest&.include?(id.to_s)
  end

  def checked_favourite_sports_show(id)
    current_active_profile&.hobbies_and_interest&.favourite_sports_show&.nil? ? false : current_active_profile&.hobbies_and_interest&.favourite_sports_show&.include?(id.to_s)
  end

  def checked_fitness_activity(id)
    current_active_profile&.hobbies_and_interest&.fitness_activity&.nil? ? false : current_active_profile&.hobbies_and_interest&.fitness_activity&.include?(id.to_s)
  end

  def checked_cuisine(id)
    current_active_profile&.hobbies_and_interest&.cuisine&.nil? ? false : current_active_profile&.hobbies_and_interest&.cuisine&.include?(id.to_s)
  end

  def checked_read(id)
    current_active_profile&.hobbies_and_interest&.read&.nil? ? false : current_active_profile&.hobbies_and_interest&.read&.include?(id.to_s)
  end

  def checked_favourite_movie(id)
    current_active_profile&.hobbies_and_interest&.favourite_movie&.nil? ? false : current_active_profile&.hobbies_and_interest&.favourite_movie&.include?(id.to_s)
  end

  def checked_favourite_tv_show(id)
    current_active_profile&.hobbies_and_interest&.favourite_tv_show&.nil? ? false : current_active_profile&.hobbies_and_interest&.favourite_tv_show&.include?(id.to_s)
  end

  def checked_music(id)
    current_active_profile&.hobbies_and_interest&.music&.nil? ? false : current_active_profile&.hobbies_and_interest&.music&.include?(id.to_s)
  end

  def checked_travel(id)
    current_active_profile&.hobbies_and_interest&.travel&.nil? ? false : current_active_profile&.hobbies_and_interest&.travel&.include?(id.to_s)
  end


end
