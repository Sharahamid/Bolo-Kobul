module LocaleHelper
  BANGLA_DIGITS = '০১২৩৪৫৬৭৮৯'.freeze

  # The current page in the other language
  def locale_switch_url(locale)
    query = request.query_parameters.merge('locale' => locale.to_s)
    "#{request.path}?#{query.to_query}"
  end

  # Numbers in Bangla digits when the site is in Bangla
  def local_digits(value)
    text = value.to_s
    I18n.locale == :bn ? text.tr('0123456789', BANGLA_DIGITS) : text
  end

  # "28 years" / "২৮ বছর"
  def years_label(age)
    return '' if age.blank?

    t('profile_card.years', age: local_digits(age))
  end

  # District names (hometown, present location)
  def district_label(name)
    return '' if name.blank?

    I18n.t("districts.#{name.to_s.downcase.gsub(/[^a-z]+/, '_').delete_suffix('_')}", default: name.to_s.humanize)
  end

  # Occupation names, e.g. "private_service" => "Private Service / Corporate"
  def occupation_label(name)
    return '' if name.blank?

    I18n.t("occupations.#{name}", default: Occupation::OCCUPATION_LABELS[name.to_s] || name.to_s.humanize)
  end

  # Religion shown by name, e.g. "Islam" => "ইসলাম" in Bangla
  def religion_label(name)
    return '' if name.blank?

    I18n.t("enums.marriage_profile.religion.#{name.to_s.downcase}", default: name.to_s)
  end

  # yes / no answers
  def yes_no_label(value)
    return '' if value.blank?

    I18n.t("enums.yes_no.#{value}", default: value.to_s.humanize)
  end

  # Label for an enum value, e.g. enum_label(:user, :created_for, 'self') => "Self" / "নিজের জন্য"
  def enum_label(model, attribute, value)
    return '' if value.blank?

    I18n.t("enums.#{model}.#{attribute}.#{value}", default: value.to_s.humanize)
  end
end
