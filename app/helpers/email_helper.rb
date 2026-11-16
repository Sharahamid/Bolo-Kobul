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

  # Small card about the member who sent a Kobul: Profile ID, match %, age, height,
  # district and education. Never a name, photo or contact details.
  # viewer = the profile reading the email (the match % is worked out for them).
  def email_profile_card(profile, viewer)
    return '' if profile.nil?

    percent = begin
      viewer ? profile.calculate_matching_percentage!(viewer).to_i : 0
    rescue StandardError => e
      Rails.logger.warn("[email card] match % for #{profile.id}: #{e.class}")
      0
    end
    details = [(years_label(profile.age) if profile.age.present?),
               ("#{local_digits(profile.height_ft)}'#{local_digits(profile.height_inch)}\"" if profile.height_ft.present?),
               (district_label(profile.hometown) if profile.hometown.present?),
               (enum_label(:marriage_profile, :highest_education_level, profile.highest_education_level) if profile.highest_education_level.present?)].compact
    card = { id: profile.unique_id, verified: profile.verified, percent: percent, details: details.join(' · '),
             photo: nil, link: profile_info_marriage_profile_url(profile) }
    render('reminder_mailer/card', m: card)
  rescue StandardError => e
    Rails.logger.warn("[email card] #{e.class}: #{e.message}")
    ''
  end
end
