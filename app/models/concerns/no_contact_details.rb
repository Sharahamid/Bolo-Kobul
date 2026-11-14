# Keeps phone numbers, email addresses and social media / messaging links out of the
# free-text parts of a profile (About me, special circumstances, about the family).
# Contact details are only shared by members themselves in chat, when they are ready.
module NoContactDetails
  extend ActiveSupport::Concern

  FIELDS = %i[about_my_self special_circumstances description].freeze

  BANGLA_DIGITS = '০১২৩৪৫৬৭৮৯'.freeze

  # 10 or more digits in a row, even with spaces, dashes, dots or brackets between them
  PHONE = /(?:\+?\d[\s\-.()\/]{0,3}){10,}/
  EMAIL = /[\w.+-]+\s*(?:@|\(\s*at\s*\)|\[\s*at\s*\])\s*[\w-]+(?:\s*(?:\.|\(\s*dot\s*\)|\[\s*dot\s*\])\s*[a-z]{2,})+/i
  LINK = %r{
    https?://\S+ | \bwww\.\S+ |
    \b(?:facebook|fb|instagram|linkedin|twitter|tiktok|youtube|telegram|whatsapp|imo|viber|snapchat|threads)\.(?:com|me|org|net)\b\S* |
    \b(?:m\.me|wa\.me|t\.me|fb\.me|x\.com|youtu\.be)/\S*
  }xi

  included do
    FIELDS.each do |field|
      validate(if: :"#{field}_changed?") { check_contact_details(field) }
    end
  end

  class_methods do
    # What kind of contact detail the text contains (:phone, :email, :link) or nil
    def contact_detail_in(text)
      plain = text.to_s.tr(BANGLA_DIGITS, '0123456789')
      return :link if plain.match?(LINK)
      return :email if plain.match?(EMAIL)
      return :phone if plain.match?(PHONE)

      nil
    end

    # The same text with contact details taken out (used for text read from a biodata)
    def without_contact_details(text)
      plain = text.to_s.tr(BANGLA_DIGITS, '0123456789')
      return text if contact_detail_in(text).nil?

      plain.gsub(LINK, '').gsub(EMAIL, '').gsub(PHONE, '').gsub(/[ \t]{2,}/, ' ').strip
    end
  end

  private

  def check_contact_details(field)
    kind = self.class.contact_detail_in(self[field])
    return unless kind

    errors.add(field, I18n.t("form.no_contact.#{kind}"))
  end
end
