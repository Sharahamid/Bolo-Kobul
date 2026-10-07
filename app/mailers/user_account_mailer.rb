class UserAccountMailer < ApplicationMailer
  include LocaleHelper

  def registration
    @user = params[:user]
    mail(to: @user.email,
         subject: t('email.subject.welcome'))
  end

  def otp_verification
    @user = params[:user]
    mail(to: @user.email,
         subject: t('email.subject.otp'))
  end

  # Sent when a member asks for their account to be deleted
  def deletion_scheduled
    @receiver = params[:user]
    @date = @receiver.deletion_date
    mail(to: @receiver.email, subject: t('email.subject.deletion', date: email_date(@date)))
  end

  def forget_password
    @notification = params[:notification]
    mail(to: @notification.recipient.email,
         subject: "Purchased notifications")
  end
end
