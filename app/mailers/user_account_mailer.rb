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

  def forget_password
    @notification = params[:notification]
    mail(to: @notification.recipient.email,
         subject: "Purchased notifications")
  end
end
