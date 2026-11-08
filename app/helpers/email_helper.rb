module EmailHelper
  def email_image_tag(image, **options)
    attachments[image] = File.read(Rails.root.join("app/assets/images/#{image}"))
    image_tag attachments[image].url, **options
  end

  # "Browse / Explore more profiles" buttons: the member's own search page (it
  # signs them in first if needed); the home page if they have no profile yet
  def browse_profiles_url(user)
    profile = user&.main_marriage_profile
    profile ? search_page_marriage_profile_url(profile) : 'https://bolokobul.com/'
  end
end
