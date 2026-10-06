class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action { Current.user = current_user }
  before_action :track_last_seen
  add_flash_types :info, :success, :danger, :warning
  helper_method :current_active_profile, :check_current_active_profile, :play_store_app?

  def current_active_profile
    marriage_profile_id = 0
    if session[:marriage_profile_id].present?
      marriage_profile_id = session[:marriage_profile_id]
    elsif current_user&.marriage_profiles.present?
      marriage_profile_id = current_user.marriage_profiles.first.id
    end
    # Only ever pick one of the signed-in user's own profiles
    @current_active_profile = current_user&.marriage_profiles&.find_by(id: marriage_profile_id)
    if @current_active_profile.nil? && current_user&.marriage_profiles.present?
      @current_active_profile = current_user.marriage_profiles.first
      session[:marriage_profile_id] = @current_active_profile.id
    end
    @current_active_profile
  end

  def check_current_active_profile
    if current_active_profile.blank?
      flash[:notice] = 'Please complete your marriage profile first'
      redirect_to new_marriage_profile_path
    end
  end

  def check_preference
    if current_active_profile.partner_preference.blank?
      flash[:notice] = 'Please set preference'
      redirect_to new_partner_preference_path
    end
  end

  protected

  # IDs of the marriage profiles that belong to the signed-in user, used to make
  # sure people can only view or change records attached to their own profiles
  def owned_profile_ids
    current_user.marriage_profiles.select(:id)
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up) do |user_params|
      user_params.permit(:name, :email, :phone_number, :created_for, :password, :password_confirmation, :refferal_promo_code)
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

  # Inside the Google Play app, butterflies can't be bought or advertised (Google Play's
  # payments policy). The page script in the layout sets this cookie only while the
  # site runs inside the Play Store app; normal browser tabs clear it.
  def play_store_app?
    cookies[:bk_play] == '1'
  end

  # Not enough butterflies: on the website, go to the purchase page; inside the Play
  # Store app, just say so
  def redirect_for_more_butterflies(website_message, flash_type: :danger)
    if play_store_app?
      flash[flash_type] = "You don't have enough butterflies for this."
      redirect_back fallback_location: root_path
    else
      flash[flash_type] = website_message
      redirect_to new_order_path
    end
  end

  def user_homepage(resource)
    if resource.created_for.present? && resource.other_as_matchmaker?
      resource.marriage_profiles.present? ? dashboard_marriage_profile_path(resource.marriage_profiles.first) : new_marriage_profile_path
    elsif resource.marriage_profiles.present?
      current_active_profile.present? && current_active_profile.partner_preference.present? ? dashboard_marriage_profile_path(resource.marriage_profiles.first) : new_partner_preference_path
    else
      new_marriage_profile_path
    end
  end

  private

  # When the member last used the site or app (saved at most once an hour); the Friday
  # reminder only goes to members who have not been here for 7 days
  def track_last_seen
    return unless current_user
    return if current_user.last_seen_at && current_user.last_seen_at > 1.hour.ago

    current_user.update_column(:last_seen_at, Time.current)
  end
end
