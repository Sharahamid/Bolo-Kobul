class UserAccountMailer < ApplicationMailer
  def registration
    @user = params[:user]
    mail(to: @user.email,
         subject: "Bolo Kobul Welcomes You To Find Your Soulmate")
  end

  def forget_password
    @notification = params[:notification]
    mail(to: @notification.recipient.email,
         subject: "Purchased notifications")
  end
end
