class KobulTwoMailer < ApplicationMailer
  # After A Sends a Request, B gets this message
  def send_request
    @sender_profile = params[:current_profile]
    @receiver = params[:profile].user
    mail(to: @receiver.email,
         subject: "Someone Wants To Chat With You!")
  end

  # After B Accept the Request, B gets this message
  def accept_request
    @current_user = params[:current_user]
    @profile = params[:profile]
    mail(to: @current_user.email,
         subject: "Begin Chatting!")
  end

  # After B Accept the Request, A gets this message
  def get_acceptance
    @sender_profile = params[:current_profile]
    @receiver = params[:profile].user
    mail(to: @receiver.email,
         subject: "Time to Chat!")
  end

  # After B Reject the Request, A gets this message
  def get_rejection
    @sender_profile = params[:current_profile]
    @receiver = params[:profile].user
    mail(to: @receiver.email,
         subject: "SORRY! Your Butterfly is on its way back")
  end
end
