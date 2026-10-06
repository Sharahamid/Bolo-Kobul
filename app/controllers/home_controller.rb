class HomeController < ApplicationController
  before_action :authenticate_user!, 
  :check_current_active_profile, 
  :check_preference, except: [:landing, :about, :email_template, :contact, :animation, :use_reference, :delete_account]

  def landing
    # Signed-in members (opening the app, or tapping the logo) go straight to their
    # dashboard instead of the sign-up page
    if user_signed_in?
      flash.keep
      # Keep the Play Store app marker (see the layout) on the way to the dashboard
      return redirect_to(params[:source] == 'play' ? "#{user_homepage(current_user)}?source=play" : user_homepage(current_user))
    end

    @user = User.new
    @success_stories = Blog.approved.success_story
  end

  def about
    @about_content = About.all.order(:display_order)
  end

  def delete_account
  end

  def contact
    @contact = Contact.last
  end

  def email_template

  end

  def animation
  end

  def use_reference
    @user = current_user
    @logged_in = current_user.present?
    if request.patch?
      if @logged_in
        earning_bf_response = params[:referral_code].present? ?
          @user.earn_bf_by_reference(params[:referral_code]) :
          'Empty promo code is not allowed'
        redirect_back fallback_location: root_path, notice: earning_bf_response
      else
        if params[:referral_code].present?
          session[:pending_referral_code] = params[:referral_code]
          redirect_to new_user_registration_path, notice: "Referral code accepted! Register now to complete your profile."
        else
          @referral_error = 'Please enter a referral code'
        end
      end
    end
  end
end
