class KobulTwoMailer < ApplicationMailer
  # After A sends a 2nd Kobul, A gets this confirmation (same as the 1st Kobul one)
  def sent
    @user = params[:user]
    @profile = params[:profile]
    mail(to: @user.email,
         subject: t('email.subject.kobul2_sent'))
  end

  # After A Sends a Request, B gets this message
  def send_request
    @sender_profile = params[:current_profile]
    @receiver_profile = params[:profile]
    @receiver = params[:profile].user
    mail(to: @receiver.email,
         subject: t('email.subject.kobul2_received'))
  end

  # 3 days after a 2nd Kobul arrived with no answer, B gets one reminder
  def reminder
    @user = params[:user]
    @profile = params[:profile]            # who sent the 2nd Kobul
    @viewer = params[:receiver_profile]    # B's own profile (for the match %)
    mail(to: @user.email,
         subject: t('email.subject.kobul2_reminder'))
  end

  # 3 days after a 1st Kobul was accepted and nobody has sent a 2nd Kobul yet
  def nudge
    @user = params[:user]
    @profile = params[:profile]            # the other member
    @viewer = params[:own_profile]
    mail(to: @user.email,
         subject: t('email.subject.kobul2_nudge', id: @profile.unique_id))
  end

  # After B Accept the Request, B gets this message
  def accept_request
    @current_user = params[:current_user]
    @profile = params[:profile]
    mail(to: @current_user.email,
         subject: t('email.subject.kobul2_you_accepted'))
  end

  # After B Accept the Request, A gets this message
  def get_acceptance
    @sender_profile = params[:current_profile]
    @receiver = params[:profile].user
    mail(to: @receiver.email,
         subject: t('email.subject.kobul2_accepted'))
  end

  # After B Reject the Request, A gets this message
  def get_rejection
    @sender_profile = params[:current_profile]
    @receiver = params[:profile].user
    mail(to: @receiver.email,
         subject: t('email.subject.kobul2_declined'))
  end

  def request_expired
    @sender_profile = params[:sender_profile]
    mail(to: @sender_profile.user.email,
         subject: t('email.subject.kobul2_expired'))
  end
end
