class ApplicationMailer < ActionMailer::Base
  default from: 'BoloKobul <noreply@bolokobul.com>'
  layout 'mailer'
  helper EmailHelper
  helper LocaleHelper
  helper NotificationBanglaHelper

  # Member emails are written in the member's chosen language (English unless they
  # picked Bangla). Admin emails override locale_recipient and stay in English.
  around_action :use_recipient_locale

  private

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
