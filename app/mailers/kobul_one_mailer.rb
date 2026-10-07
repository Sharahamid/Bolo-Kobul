class KobulOneMailer < ApplicationMailer
  # After A Sends a Request, A gets this message
  def send_request
    @user = params[:user]
    @profile = params[:profile]
    mail(to: @user.email,
         subject: t('email.subject.kobul1_sent'))
  end

  # When A Send request, B gets this message
  def receive_request
    @user = params[:user]
    mail(to: @user.email,
         subject: t('email.subject.kobul1_received'))
  end

  # When B accepts the request, B gets this message.
  def accept_request
    @user = params[:user]
    @profile = params[:profile]
    mail(to: @user.email,
         subject: t('email.subject.kobul1_you_accepted'))
  end

  # When B accepts the request, A gets this message
  def get_acceptance
    @user = params[:user]
    @profile = params[:profile]
    mail(to: @user.email,
         subject: t('email.subject.kobul1_accepted'))
  end

  # When B rejects the request, A gets this message
  def get_rejection
    @user = params[:user]
    @profile = params[:profile]
    mail(to: @user.email,
         subject: t('email.subject.kobul1_declined'))
  end

  # After expired a request, A will get this message
  def request_expired
    @sender_profile = params[:sender_profile]
    mail(to: @sender_profile.user.email,
         subject: t('email.subject.kobul1_expired'))
  end
end
