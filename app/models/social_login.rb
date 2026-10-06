# "Continue with Google / Facebook"
module SocialLogin
  PROVIDERS = {
    google_oauth2: { label: 'Google', keys: %w[GOOGLE_CLIENT_ID GOOGLE_CLIENT_SECRET] },
    facebook: { label: 'Facebook', keys: %w[FACEBOOK_APP_ID FACEBOOK_APP_SECRET] }
  }.freeze

  # Providers whose keys are set; only these get a button
  def self.providers
    PROVIDERS.select { |_, provider| provider[:keys].all? { |key| ENV[key].present? } }.keys
  end

  def self.label(provider)
    PROVIDERS.dig(provider.to_sym, :label) || provider.to_s.titleize
  end

  # Google says whether the address is verified; Facebook only shares confirmed addresses
  def self.verified_email(auth)
    email = auth.info&.email.to_s.strip.downcase.presence
    return unless email
    return email unless auth.provider.to_s == 'google_oauth2'

    auth.extra&.raw_info&.email_verified.to_s == 'true' ? email : nil
  end
end
