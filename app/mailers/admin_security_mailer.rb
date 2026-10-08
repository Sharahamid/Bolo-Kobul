class AdminSecurityMailer < ApplicationMailer
  def new_device_sign_in(admin, ip, user_agent, signed_in_at)
    @admin = admin
    @ip = ip
    @browser = AdminSecurityMailer.describe_browser(user_agent)
    @user_agent = user_agent
    @signed_in_at = signed_in_at
    mail(to: admin.email, subject: "New sign-in to the Bolo Kobul admin panel")
  end

  # "Chrome on Android" from a browser's user agent text
  def self.describe_browser(user_agent)
    ua = user_agent.to_s
    browser = case ua
              when /Edg\//i then 'Edge'
              when /OPR\/|Opera/i then 'Opera'
              when /SamsungBrowser/i then 'Samsung Internet'
              when /Firefox\//i then 'Firefox'
              when /Chrome\//i then 'Chrome'
              when /Safari\//i then 'Safari'
              else 'Unknown browser'
              end
    system = case ua
             when /Android/i then 'Android'
             when /iPhone|iPad|iPod/i then 'iPhone/iPad'
             when /Windows/i then 'Windows'
             when /Mac OS X|Macintosh/i then 'Mac'
             when /Linux/i then 'Linux'
             else 'unknown device'
             end
    "#{browser} on #{system}"
  end

  private

  # Emails to the Bolo Kobul team are always in English
  def locale_recipient
    nil
  end
end
