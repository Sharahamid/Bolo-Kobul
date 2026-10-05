class UserAccountMailer < ApplicationMailer
  def registration
    @user = params[:user]
    mail(to: @user.email,
         subject: "Welcome to Bolo Kobul! Find Your Soulmate")
  end

  def otp_verification
    @user = params[:user]
    mail(to: @user.email,
         subject: "Your Bolo Kobul Verification Code")
  end

  # Sent when a member asks for their account to be deleted
  def deletion_scheduled
    @receiver = params[:user]
    @date = @receiver.deletion_date
    mail(to: @receiver.email, subject: "Your Bolo Kobul account will be deleted on #{@date.strftime('%-d %B %Y')}")
  end

  def forget_password
    @notification = params[:notification]
    mail(to: @notification.recipient.email,
         subject: "Purchased notifications")
  end
end
