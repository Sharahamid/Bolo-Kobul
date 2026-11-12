# On/off switches for the site's SMS and emails, set in Admin > Manage Site > Messages On Off.
# One row. Every switch starts ON; a master switch turns a whole channel off.
# If the table is missing (before the migration is run) everything stays ON.
class MessageSetting < ApplicationRecord
  SMS_KINDS = %i[otp kobul purchase text_alerts].freeze

  # Which switch each email belongs to (by mailer). Mailers not listed (e.g. Devise password
  # reset) are always sent.
  EMAIL_GROUPS = {
    'UserAccountMailer' => :account,
    'KobulOneMailer' => :kobul,
    'KobulTwoMailer' => :kobul,
    'ChatMessageMailer' => :chat,
    'NotificationMailer' => :purchase,
    'ReminderMailer' => :reminders,
    'AdminSupportMailer' => :admin,
    'AdminSecurityMailer' => :admin,
    'WeeklyReportMailer' => :admin
  }.freeze

  def self.current
    first || create!
  end

  def self.sms_allowed?(kind)
    return true unless SMS_KINDS.include?(kind.to_sym)

    s = current
    s.sms_all && s.public_send("sms_#{kind}")
  rescue StandardError => e
    Rails.logger.warn("[messages] switch check failed, sending anyway: #{e.class}")
    true
  end

  def self.email_allowed?(mailer_name)
    group = EMAIL_GROUPS[mailer_name.to_s]
    return true unless group

    s = current
    s.email_all && s.public_send("email_#{group}")
  rescue StandardError => e
    Rails.logger.warn("[messages] switch check failed, sending anyway: #{e.class}")
    true
  end
end
