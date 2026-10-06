# "Continue with Google / Facebook"
# - an account already linked to this Google/Facebook login, or with the same verified
#   email: logged in (or sent to phone verification if that isn't done yet)
# - otherwise: a short "finish sign-up" page asks for the mobile number, and the phone is
#   verified by SMS code like every other new account
class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    handle_social_login
  end

  def facebook
    handle_social_login
  end

  def failure
    flash[:warning] = "We couldn't sign you in with #{SocialLogin.label(params[:strategy] || failed_strategy&.name)}. Please try again, or log in with your email or mobile."
    redirect_to root_path
  end

  private

  def handle_social_login
    auth = request.env['omniauth.auth']
    kind = SocialLogin.label(auth.provider)
    email = SocialLogin.verified_email(auth)

    user = User.find_by(provider: auth.provider, uid: auth.uid.to_s)
    if user.nil? && email
      user = User.find_by(email: email)
      user&.update_columns(provider: auth.provider, uid: auth.uid.to_s) if user && user.uid.blank?
    end

    if user
      if user.active_for_authentication?
        sign_in :user, user
        Devise::Hooks::Proxy.new(warden).remember_me(user)
        flash[:success] = "Signed in with #{kind}."
        redirect_to after_sign_in_path_for(user)
      else
        redirect_to show_verify_user_path(user)
      end
    elsif email
      session[:social_signup] = { 'provider' => auth.provider, 'uid' => auth.uid.to_s, 'name' => auth.info&.name.to_s.first(50),
                                  'email' => email, 'at' => Time.current.to_i }
      redirect_to new_social_signup_path
    else
      flash[:warning] = "Your #{kind} account didn't share a verified email address. Please register with the form instead."
      redirect_to root_path
    end
  end
end
