# Phone numbers are typed in many ways ("01733404723", "+880 1733404723",
# "8801733404723"). Bangladeshi mobile numbers are saved in one form, +8801XXXXXXXXX,
# and recognised in any of these forms when checking for duplicates or logging in,
# including numbers saved the old way.
module PhoneNumber
  BD_MOBILE = /\A(?:00880|880|0)?(1[3-9]\d{8})\z/

  # Spaces, dashes, dots and brackets removed; a leading + kept
  def self.clean(raw)
    text = raw.to_s.strip
    plus = text.start_with?('+') ? '+' : ''
    plus + text.gsub(/[^0-9]/, '')
  end

  # "1733404723" for a Bangladeshi mobile number, nil for anything else
  def self.bd_local(raw)
    clean(raw).delete('+')[BD_MOBILE, 1]
  end

  # The form a number is saved in
  def self.normalize(raw)
    local = bd_local(raw)
    local ? "+880#{local}" : clean(raw)
  end

  # Records whose phone number is this number, however either was typed
  def self.matching(scope, raw, column: 'phone_number')
    local = bd_local(raw)
    return scope.where(column => clean(raw)) unless local

    scope.where("regexp_replace(#{column}, '[^0-9]', '', 'g') ~ ?", "^(00880|880|0)?#{local}$")
  end

  # The form the SMS gateway gets: 01XXXXXXXXX by default, or 8801XXXXXXXXX when
  # SMS_RECEIVER_FORMAT is "880" in application.yml
  def self.for_sms(raw)
    local = bd_local(raw)
    return clean(raw) unless local

    ENV['SMS_RECEIVER_FORMAT'].to_s == '880' ? "880#{local}" : "0#{local}"
  end
end
