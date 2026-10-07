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

  # Label for an enum value, e.g. enum_label(:user, :created_for, 'self') => "Self" / "নিজের জন্য"
  def enum_label(model, attribute, value)
    return '' if value.blank?

    I18n.t("enums.#{model}.#{attribute}.#{value}", default: value.to_s.humanize)
  end
end
