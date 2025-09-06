class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?
  add_flash_types :info, :success, :danger, :warning
  helper_method :current_active_profile, :check_current_active_profile

  def current_active_profile
    marriage_profile_id = 0
    if session[:marriage_profile_id].present?
      marriage_profile_id = session[:marriage_profile_id]
    elsif current_user&.marriage_profiles.present?
      marriage_profile_id = current_user.marriage_profiles.first.id
    end
    @current_active_profile = MarriageProfile.find_by_id(marriage_profile_id)
  end

  def check_current_active_profile
    if current_active_profile.blank?
      flash[:notice] = 'Please complete your marriage profile first.'
      redirect_to new_marriage_profile_path
    end
  end

  def check_preference
    if current_active_profile.partner_preference.blank?
      flash[:notice] = 'Please set preference.'
      redirect_to new_partner_preference_path
    end
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up) do |user_params|
      user_params.permit(:name, :email, :phone_number, :created_for, :password, :password_confirmation)
    end
  end

  def after_sign_in_path_for(resource)
    if resource.is_a?(AdminUser)
      shefali007_root_path
    else
      stored_location_for(resource) || resource.is_a?(User) ? user_homepage(resource) : root_path
    end
  end

  # Overwriting the sign_out redirect path method
  def after_sign_out_path_for(resource)
    root_path
  end

  def user_homepage(resource)
    if resource.created_for.present? && resource.other_as_matchmaker?
      resource.advertiser_profile.present? ? advertiser_profile_path(resource) : new_advertiser_profile_path
    elsif resource.marriage_profiles.present?
      current_active_profile.present? && current_active_profile.partner_preference.present? ? dashboard_marriage_profile_path(resource.marriage_profiles.first) : new_partner_preference_path
    else
      new_marriage_profile_path
    end
  end
end
