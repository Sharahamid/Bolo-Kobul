class KobulTwoMailer < ApplicationMailer
  # After A Sends a Request, B gets this message
  def send_request
    @sender_profile = params[:current_profile]
    @receiver = params[:profile].user
    mail(to: @receiver.email,
         subject: "🦋 Kobul 2 Request Received!")
  end

  # After B Accept the Request, B gets this message
  def accept_request
    @current_user = params[:current_user]
    @profile = params[:profile]
    mail(to: @current_user.email,
         subject: "🦋 Kobul 2 Accepted - Start Chatting!")
  end

  # After B Accept the Request, A gets this message
  def get_acceptance
    @sender_profile = params[:current_profile]
    @receiver = params[:profile].user
    mail(to: @receiver.email,
         subject: "🦋 Kobul 2 Accepted!")
  end

  # After B Reject the Request, A gets this message
  def get_rejection
    @sender_profile = params[:current_profile]
    @receiver = params[:profile].user
    mail(to: @receiver.email,
         subject: "🦋 Kobul 2 Not Accepted")
  end

  def request_expired
    @sender_profile = params[:sender_profile]
    mail(to: @sender_profile.user.email,
         subject: "🦋 Kobul 2 Expired")
  end
end
