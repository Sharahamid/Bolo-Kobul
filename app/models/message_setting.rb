# On/off switches for the site's SMS and emails, set in Admin > Manage Site > Messages On / Off.
# One row: a master switch per channel (sms_all, email_all) plus off_keys, the list of
# individual messages that are switched OFF. Everything is ON unless listed there.
# If the table is missing or anything goes wrong, messages are sent as normal.
class MessageSetting < ApplicationRecord
  # [key, section, label shown in admin]. SMS keys match SmsService.call(kind:);
  # email keys are "MailerClass#action".
  CATALOG = [
    ['sms.otp', 'SMS: account', 'Sign-up and login code (WARNING: if OFF, the code is emailed instead)'],
    ['sms.kobul1_sent', 'SMS: 1st Kobul', 'To the sender: "Your 1st Kobul has been sent!"'],
    ['sms.kobul1_received', 'SMS: 1st Kobul', 'To the receiver: "Someone has sent you a 1st Kobul"'],
    ['sms.kobul1_you_accepted', 'SMS: 1st Kobul', 'To the person who accepted: "Check out the profile…"'],
    ['sms.kobul1_accepted', 'SMS: 1st Kobul', 'To the sender: "Your 1st Kobul was accepted!"'],
    ['sms.kobul1_declined', 'SMS: 1st Kobul', 'To the sender: "Your 1st Kobul was not accepted"'],
    ['sms.kobul1_expired', 'SMS: 1st Kobul', 'To the sender: "Your 1st Kobul has expired" (after 7 days)'],
    ['sms.kobul2_received', 'SMS: 2nd Kobul', 'To the receiver: "Someone has sent you a 2nd Kobul"'],
    ['sms.kobul2_you_accepted', 'SMS: 2nd Kobul', 'To the person who accepted: "You can now start chatting"'],
    ['sms.kobul2_accepted', 'SMS: 2nd Kobul', 'To the sender: "Your 2nd Kobul was accepted"'],
    ['sms.kobul2_declined', 'SMS: 2nd Kobul', 'To the sender: "Your 2nd Kobul was not accepted"'],
    ['sms.purchase', 'SMS: other', 'Purchase confirmation (butterflies, services): "Your purchase was successful!"'],
    ['sms.bk_plus_purchase', 'SMS: other', 'BK+ purchase: "Payment received. Welcome to BK+! … active until …"'],
    ['sms.text_alerts', 'SMS: other', 'Text Alerts (members who paid butterflies for SMS alerts)'],

    ['email.UserAccountMailer#registration', 'Emails: account', 'Welcome email after sign-up'],
    ['email.UserAccountMailer#otp_verification', 'Emails: account', 'Login / sign-up code by email (WARNING: needed if SMS codes fail)'],
    ['email.UserAccountMailer#deletion_scheduled', 'Emails: account', 'Account deletion confirmation'],
    ['email.KobulOneMailer#send_request', 'Emails: 1st Kobul', 'To the sender: 1st Kobul sent'],
    ['email.KobulOneMailer#receive_request', 'Emails: 1st Kobul', 'To the receiver: 1st Kobul received'],
    ['email.KobulOneMailer#accept_request', 'Emails: 1st Kobul', 'To the person who accepted: you accepted a 1st Kobul'],
    ['email.KobulOneMailer#get_acceptance', 'Emails: 1st Kobul', 'To the sender: 1st Kobul accepted'],
    ['email.KobulOneMailer#get_rejection', 'Emails: 1st Kobul', 'To the sender: 1st Kobul declined'],
    ['email.KobulOneMailer#expiry_reminder', 'Emails: 1st Kobul', 'To the receiver: reminder 2 days before an unanswered 1st Kobul expires'],
    ['email.KobulOneMailer#request_expired', 'Emails: 1st Kobul', 'To the sender: 1st Kobul expired'],
    ['email.KobulTwoMailer#send_request', 'Emails: 2nd Kobul', 'To the receiver: 2nd Kobul received'],
    ['email.KobulTwoMailer#accept_request', 'Emails: 2nd Kobul', 'To the person who accepted: you accepted a 2nd Kobul'],
    ['email.KobulTwoMailer#get_acceptance', 'Emails: 2nd Kobul', 'To the sender: 2nd Kobul accepted'],
    ['email.KobulTwoMailer#get_rejection', 'Emails: 2nd Kobul', 'To the sender: 2nd Kobul declined'],
    ['email.KobulTwoMailer#request_expired', 'Emails: 2nd Kobul', 'To the sender: 2nd Kobul expired'],
    ['email.ChatMessageMailer#new_message', 'Emails: members', 'New chat message alert'],
    ['email.NotificationMailer#purchased_notification', 'Emails: members', 'Purchase receipt (butterflies, services and BK+)'],
    ['email.BkPlusMailer#welcome', 'Emails: members', 'BK+ welcome / extended email, with all BK+ features'],
    ['email.ReminderMailer#weekly', 'Emails: members', 'Weekly reminder and matches email (every other Friday)'],
    ['email.AdminSupportMailer#new_ticket', 'Emails: to the Bolo Kobul team', 'New support ticket'],
    ['email.AdminSupportMailer#new_story', 'Emails: to the Bolo Kobul team', 'New success story submitted'],
    ['email.AdminSupportMailer#account_deletion_requested', 'Emails: to the Bolo Kobul team', 'Account deletion requested'],
    ['email.AdminSupportMailer#profile_reported', 'Emails: to the Bolo Kobul team', 'Profile reported'],
    ['email.AdminSupportMailer#new_payment', 'Emails: to the Bolo Kobul team', 'New payment received'],
    ['email.AdminSupportMailer#new_listing', 'Emails: to the Bolo Kobul team', 'New Wedding Shopping List entry (paid, waiting for approval)'],
    ['email.MarketPlaceMailer#received', 'Emails: to businesses', 'Wedding Shopping List: payment received, under review'],
    ['email.MarketPlaceMailer#approved', 'Emails: to businesses', 'Wedding Shopping List: listing approved and live'],
    ['email.MarketPlaceMailer#renewal_reminder', 'Emails: to businesses', 'Wedding Shopping List: listing ends in 14 days'],
    ['email.AdminSupportMailer#sms_problem', 'Emails: to the Bolo Kobul team', 'SMS balance low / SMS problem'],
    ['email.AdminSecurityMailer#new_device_sign_in', 'Emails: to the Bolo Kobul team', 'Admin login from a new device'],
    ['email.WeeklyReportMailer#weekly_report', 'Emails: to the Bolo Kobul team', 'Twice-monthly site report']
  ].freeze
  ALL_KEYS = CATALOG.map(&:first).freeze

  def self.current
    first || create!
  end

  def self.sms_allowed?(kind)
    s = current
    s.sms_all && !s.off?("sms.#{kind}")
  rescue StandardError => e
    Rails.logger.warn("[messages] switch check failed, sending anyway: #{e.class}")
    true
  end

  def self.email_allowed?(mailer_name, action)
    s = current
    s.email_all && !s.off?("email.#{mailer_name}##{action}")
  rescue StandardError => e
    Rails.logger.warn("[messages] switch check failed, sending anyway: #{e.class}")
    true
  end

  def off?(key)
    Array(off_keys).include?(key)
  end

  # For the admin form: the ticked boxes are the messages that are ON
  def on_keys
    ALL_KEYS - Array(off_keys)
  end

  def on_keys=(keys)
    self.off_keys = ALL_KEYS - Array(keys).map(&:to_s).reject(&:blank?)
  end
end
