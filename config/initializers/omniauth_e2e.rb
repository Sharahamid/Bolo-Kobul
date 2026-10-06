# Browser tests only (local development with E2E_SOCIAL_LOGIN=1): "Continue with Google"
# skips Google and signs in as the email in the bk_e2e_social_email cookie.
if Rails.env.development? && ENV['E2E_SOCIAL_LOGIN'] == '1'
  OmniAuth.config.test_mode = true
  OmniAuth.config.before_request_phase = lambda do |env|
    email = Rack::Request.new(env).cookies['bk_e2e_social_email'].to_s
    %i[google_oauth2 facebook].each do |provider|
      OmniAuth.config.mock_auth[provider] = OmniAuth::AuthHash.new(
        provider: provider.to_s, uid: "e2e-#{provider}-#{email}",
        info: { email: email, name: 'Social Tester' },
        extra: { raw_info: { email_verified: true } }
      )
    end
  end
end
