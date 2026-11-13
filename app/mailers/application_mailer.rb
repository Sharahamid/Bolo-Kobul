class ApplicationMailer < ActionMailer::Base
  # The sender of every email. MAIL_FROM (server's config/application.yml) changes it, e.g. to
  # the Google Workspace mailbox that sends while Mailgun is unavailable
  SENDER = ENV['MAIL_FROM'].presence || 'Bolo Kobul <noreply@bolokobul.com>'
  default from: SENDER
  layout 'mailer'
  helper EmailHelper
  helper LocaleHelper
  helper NotificationBanglaHelper

  # Member emails are written in the member's chosen language (English unless they
  # picked Bangla). Admin emails override locale_recipient and stay in English.
  around_action :use_recipient_locale

  # Admin > Manage Site > Messages On / Off can stop a group of emails
  after_action :apply_message_switches

  private

  def apply_message_switches
    if MessageSetting.email_allowed?(self.class.name, action_name)
      MessageLog.record(:email, "#{self.class.name}##{action_name}") if message.to.present?
      return
    end

    Rails.logger.info("[mail] #{self.class.name}##{action_name} not sent (switched off in admin)")
    message.perform_deliveries = false
  end

  def use_recipient_locale(&block)
    locale = locale_recipient.try(:locale).to_s
    locale = I18n.default_locale.to_s unless I18n.available_locales.map(&:to_s).include?(locale)
    I18n.with_locale(locale, &block)
  end

  def locale_recipient
    given = params || {}
    given[:user] || given[:current_user] || given[:notification]&.recipient ||
      given[:sender_profile]&.user || given[:profile]&.user
  end
end
