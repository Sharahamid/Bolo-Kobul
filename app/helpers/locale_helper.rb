module LocaleHelper
  BANGLA_DIGITS = '০১২৩৪৫৬৭৮৯'.freeze
  BANGLA_MONTHS = %w[জানুয়ারি ফেব্রুয়ারি মার্চ এপ্রিল মে জুন জুলাই আগস্ট সেপ্টেম্বর অক্টোবর নভেম্বর ডিসেম্বর].freeze

  # "6 November 2026" / "৬ নভেম্বর ২০২৬"
  def local_date(date)
    return '' if date.blank?
    return date.strftime('%-d %B %Y') unless I18n.locale == :bn

    "#{local_digits(date.day)} #{BANGLA_MONTHS[date.month - 1]} #{local_digits(date.year)}"
  end

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

    I18n.t("districts.#{name.to_s.downcase.gsub(/[^a-z]+/, '_').delete_suffix('_')}", default: name.to_s)
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

  # Fixed choice lists from UserConcern (hobbies, food habits, languages...), e.g.
  # choice_label(:hobbies, 'Photography') => "ফটোগ্রাফি". English shows the name as stored.
  def choice_label(list, name)
    return '' if name.blank?

    slug = name.to_s.downcase.gsub(/[^a-z0-9]+/, '_').gsub(/\A_+|_+\z/, '')
    I18n.t("choices.#{list.to_s.downcase}.#{slug}", default: name.to_s)
  end

  # Dropdown options for a UserConcern hash (name => stored value)
  def choice_options(list)
    User.const_get(list.to_s.upcase).map { |name, value| [choice_label(list, name), value] }
  end

  # Dropdown options for enum values: the label is translated, the value sent stays the same.
  # enum_options(:marriage_profile, :religion, %w[islam other]) => [["ইসলাম", "islam"], ...]
  def enum_options(model, attribute, values)
    values.map do |value|
      label = I18n.t("enums.#{model}.#{attribute}.#{value}",
                     default: [:"enums.#{model}.#{attribute}.#{value.to_s.downcase}", value.to_s.humanize])
      [label, value]
    end
  end

  # District dropdown options; English names stay exactly as stored
  def district_options(names)
    names.map { |name| [I18n.locale == :bn ? district_label(name) : name, name] }
  end

  # Number options such as heights (feet, inches) with Bangla digits in Bangla
  def number_options(options)
    options.map { |label, value| [local_digits(label), value] }
  end

  # Yes / No dropdown (User::BOOLEAN_DATA: Yes => '0', No => '1')
  def yes_no_options
    User::BOOLEAN_DATA.map { |label, value| [yes_no_label(label.to_s.downcase), value] }
  end

  # Label for an enum value, e.g. enum_label(:user, :created_for, 'self') => "Self" / "নিজের জন্য"
  def enum_label(model, attribute, value)
    return '' if value.blank?

    I18n.t("enums.#{model}.#{attribute}.#{value}", default: value.to_s.humanize)
  end
end
