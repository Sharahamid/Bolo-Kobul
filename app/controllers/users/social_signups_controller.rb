# Last step of signing up with Google/Facebook: name, mobile number and who the profile
# is for. The email comes from Google/Facebook; the phone is then verified by SMS code.
class Users::SocialSignupsController < ApplicationController
  EXPIRES_IN = 30.minutes

  before_action :load_social_data

  def new
    @user = User.new(name: @data['name'], email: @data['email'])
  end

  def create
    @user = User.new(params.require(:user).permit(:name, :phone_number, :created_for))
    @user.email = @data['email']
    @user.provider = @data['provider']
    @user.uid = @data['uid']
    # They log in with Google/Facebook; "Forgot Password" lets them set a password later
    @user.password = @user.password_confirmation = "#{SecureRandom.base58(24)}a1"

    if @user.save
      session.delete(:social_signup)
      session[:ga_event] = 'sign_up'
      if session[:pending_referral_code].present?
        @user.earn_bf_by_reference(session.delete(:pending_referral_code))
      end
      if @user.send_otp
        flash[:info] = 'Almost done! Enter the verification code we sent to your mobile.'
      else
        flash[:warning] = "Your account is created, but we couldn't send your verification code just now. Please tap Resend Code in a minute."
      end
      redirect_to show_verify_user_path(@user)
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def load_social_data
    @data = session[:social_signup]
    return if @data.present? && @data['at'].to_i > EXPIRES_IN.ago.to_i

    session.delete(:social_signup)
    flash[:warning] = 'Please choose Continue with Google or Facebook again.'
    redirect_to root_path
  end
end
