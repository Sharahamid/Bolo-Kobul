class KobulTwoMailer < ApplicationMailer
  # After A Sends a Request, B gets this message
  def send_request
    @sender_profile = params[:current_profile]
    @receiver = params[:profile].user
    mail(to: @receiver.email,
         subject: "Someone wants to chat with you!")
  end

  # After B Accept the Request, B gets this message
  def accept_request
    @current_user = params[:current_user]
    @profile = params[:profile]
    mail(to: @current_user.email,
         subject: "You are now connected - start chatting!")
  end

  # After B Accept the Request, A gets this message
  def get_acceptance
    @sender_profile = params[:current_profile]
    @receiver = params[:profile].user
    mail(to: @receiver.email,
         subject: "Your chat request was accepted - Time to Chat!")
  end

  # After B Reject the Request, A gets this message
  def get_rejection
    @sender_profile = params[:current_profile]
    @receiver = params[:profile].user
    mail(to: @receiver.email,
         subject: "Your chat request was not accepted this time")
  end

  def request_expired
    @sender_profile = params[:sender_profile]
    mail(to: @sender_profile.user.email,
         subject: "Your chat request has expired")
  end
end
