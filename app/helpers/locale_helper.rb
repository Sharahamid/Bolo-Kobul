module LocaleHelper
  BANGLA_DIGITS = '০১২৩৪৫৬৭৮৯'.freeze
  BANGLA_MONTHS = %w[জানুয়ারি ফেব্রুয়ারি মার্চ এপ্রিল মে জুন জুলাই আগস্ট সেপ্টেম্বর অক্টোবর নভেম্বর ডিসেম্বর].freeze

  # "6 November 2026" / "৬ নভেম্বর ২০২৬"
  def local_date(date)
    return '' if date.blank?
    return date.strftime('%-d %B %Y') unless I18n.locale == :bn

    "#{local_digits(date.day)} #{BANGLA_MONTHS[date.month - 1]} #{local_digits(date.year)}"
  end

  # Dates in emails: "7 November 2026" / "৭ নভেম্বর ২০২৬"
  def email_date(date)
    local_date(date)
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

  # Marital status choices for a profile. "Widow or widower" shows as "Widow" for women and
  # "Widower" for men; the form switches it when the gender is chosen (data-widow / data-widower).
  def marital_status_options(gender)
    widow = I18n.t('enums.marital_gendered.widow')
    widower = I18n.t('enums.marital_gendered.widower')
    enum_options(:marriage_profile, :marital_status, MarriageProfile::SELECTABLE_MARITAL_STATUSES).map do |label, value|
      next [label, value] unless value.to_s == 'widow_or_widower'

      shown = { 'female' => widow, 'male' => widower }.fetch(gender.to_s, label)
      [shown, value, { data: { both: label, widow: widow, widower: widower } }]
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

  # Hover text on Kobul buttons, with the real butterfly costs from Admin > Butterfly Config
  def kobul_tip(key)
    config = ButterflyConfig.last
    n1 = config&.profile_view_butterflies.to_i
    n2 = config&.chat_butterflies.to_i
    t("kobul.tip.#{key}",
      n1: local_digits(n1), n2: local_digits(n2),
      b1: "#{n1} #{n1 == 1 ? 'butterfly' : 'butterflies'}",
      b2: "#{n2} #{n2 == 1 ? 'butterfly' : 'butterflies'}")
  end

  # "What happens now" box shown before a Kobul is sent or accepted (see kobul_explain.js
  # in the layout). kind: :send1, :send2, :accept1, :accept2
  def kobul_explain_data(kind, profile)
    costs = bk_costs
    n = %i[send1 accept1].include?(kind) ? costs[:n1] : costs[:n2]
    balance = current_user&.butterfly_number.to_i
    {
      'bk-explain' => kind.to_s,
      'bk-explain-title' => t("bkx.explain.#{kind}.title", id: profile&.unique_id),
      'bk-explain-lines' => [
        t('bkx.explain.cost', count: n, n: local_digits(n), balance: local_digits(balance)),
        t("bkx.explain.#{kind}.back"),
        t("bkx.explain.#{kind}.then")
      ].to_json,
      'bk-explain-ok' => t("bkx.explain.#{kind}.ok"),
      'bk-explain-low' => (balance < n ? t('bkx.explain.low', n: local_digits(n)) : '')
    }
  end

  def bk_costs
    @bk_costs ||= begin
      config = ButterflyConfig.last
      { n1: config&.profile_view_butterflies.to_i, n2: config&.chat_butterflies.to_i,
        price: config&.butterfly_price.to_f, free: config&.num_of_free_butterfly.to_i }
    end
  end

  # "1 butterfly" / "3 butterflies" / "৩টি প্রজাপতি"
  def butterflies_label(count)
    t(count == 1 ? 'bkx.pricing.butterfly' : 'bkx.pricing.butterflies', n: local_digits(count))
  end

  # Taka amounts without ".0": 1500.0 -> "1,500"
  def taka(amount)
    local_digits(number_with_delimiter(amount.to_f.round(0).to_i))
  end

  # Wedding Shopping category names in the current language
  def market_type_label(name)
    t("bkx.marketplace_types.#{name.to_s.parameterize(separator: '_')}", default: name.to_s.titleize)
  end
end
