# A browser an admin has signed in to the admin panel from. Signing in from a
# browser not on the list emails the admin, so an unknown login is noticed.
class AdminKnownDevice < ApplicationRecord
  COOKIE = :bk_admin_device

  belongs_to :admin_user

  def self.digest(token)
    Digest::SHA256.hexdigest(token.to_s)
  end

  # Called after every admin sign-in. Emails the admin when the browser is new to them.
  def self.check_sign_in(admin, request, cookies)
    token = cookies.signed[COOKIE].to_s
    device = admin.admin_known_devices.find_by(token_digest: digest(token)) if token.present?
    details = { user_agent: request.user_agent.to_s[0, 255], ip: request.remote_ip, last_seen_at: Time.current }

    if device
      device.update_columns(details)
      return
    end

    token = SecureRandom.urlsafe_base64(32)
    admin.admin_known_devices.create!(details.merge(token_digest: digest(token)))
    cookies.signed[COOKIE] = { value: token, expires: 10.years, httponly: true,
                               secure: Rails.env.production?, same_site: :lax }
    AdminSecurityMailer.new_device_sign_in(admin, details[:ip], details[:user_agent], details[:last_seen_at]).deliver_later
  rescue => e
    # A problem here must never stop an admin from signing in
    Rails.logger.error("[admin-device] #{e.class}: #{e.message}")
  end
end
