class KobulOneMailer < ApplicationMailer
  # After A Sends a Request, A gets this message
  def send_request
    @user = params[:user]
    @profile = params[:profile]
    mail(to: @user.email,
         subject: "🦋 Kobul 1 Sent!")
  end

  # When A Send request, B gets this message
  def receive_request
    @user = params[:user]
    mail(to: @user.email,
         subject: "🦋 You received a Kobul 1!")
  end

  # When B accepts the request, B gets this message.
  def accept_request
    @user = params[:user]
    @profile = params[:profile]
    mail(to: @user.email,
         subject: "🦋 Kobul 1 Accepted!")
  end

  # When B accepts the request, A gets this message
  def get_acceptance
    @user = params[:user]
    @profile = params[:profile]
    mail(to: @user.email,
         subject: "🦋 Great News - Kobul 1 Accepted!")
  end

  # When B rejects the request, A gets this message
  def get_rejection
    @user = params[:user]
    @profile = params[:profile]
    mail(to: @user.email,
         subject: "🦋 Kobul 1 Not Accepted")
  end

  # After expired a request, A will get this message
  def request_expired
    @sender_profile = params[:sender_profile]
    mail(to: @sender_profile.user.email,
         subject: "🦋 Kobul 1 Expired")
  end
end
