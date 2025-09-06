class KobulOneMailer < ApplicationMailer
  # After A Sends a Request, A gets this message
  def send_request
    @user = params[:user]
    @profile = params[:profile]
    mail(to: @user.email,
         subject: "Your Butterfly has reached its Destination!")
  end

  # When A Send request, B gets this message
  def receive_request
    @user = params[:user]
    mail(to: @user.email,
         subject: "You Have Received A Butterfly!")
  end

  # When B accepts the request, B gets this message.
  def accept_request
    @user = params[:user]
    @profile = params[:profile]
    mail(to: @user.email,
         subject: "Learn More About Your Potential Prospect")
  end

  # When B accepts the request, A gets this message
  def get_acceptance
    @user = params[:user]
    @profile = params[:profile]
    mail(to: @user.email,
         subject: "Your Butterfly Has Been Accepted!")
  end

  # When B rejects the request, A gets this message
  def get_rejection
    @user = params[:user]
    @profile = params[:profile]
    mail(to: @user.email,
         subject: "SORRY! Your Butterfly is on its ways back")
  end

  # After expired a request, A will get this message
  def request_expired
    @sender_profile = params[:sender_profile]
    mail(to: @sender_profile.user.email,
         subject: "SORRY! Your Butterfly has Returned")
  end
end
