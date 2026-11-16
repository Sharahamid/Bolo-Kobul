class UserAccountMailer < ApplicationMailer
  include LocaleHelper

  def registration
    @user = params[:user]
    mail(to: @user.email,
         subject: t('email.subject.welcome'))
  end

  def otp_verification
    @user = params[:user]
    mail(to: @user.email,
         subject: t('email.subject.otp'))
  end

  # Sent when a member asks for their account to be deleted
  def deletion_scheduled
    @receiver = params[:user]
    @date = @receiver.deletion_date
    mail(to: @receiver.email, subject: t('email.subject.deletion', date: email_date(@date)))
  end

  # When a member's butterflies drop to a few (low) or to zero (out)
  def butterflies_low
    @user = params[:user]
    @count = params[:count].to_i
    mail(to: @user.email,
         subject: @count.zero? ? t('email.subject.bf_out') : t('email.subject.bf_low', count: @count, n: local_digits(@count)))
  end

  # When a friend joins with the member's referral code and they earn a free butterfly
  def referral_reward
    @user = params[:user]
    @friend_name = params[:friend_name].to_s
    mail(to: @user.email,
         subject: t('email.subject.referral_reward'))
  end
end
