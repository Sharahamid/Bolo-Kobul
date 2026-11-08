class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  around_action :switch_locale
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action { Current.user = current_user }
  before_action :track_last_seen
  add_flash_types :info, :success, :danger, :warning
  helper_method :current_active_profile, :check_current_active_profile, :play_store_app?

  # A form left open for a long time (or reopened in the app after the phone cleared its
  # cookies) carries an out-of-date security token. Instead of a "500 Internal Server
  # Error" page, send the person back to the form with a short message to try again.
  rescue_from ActionController::InvalidAuthenticityToken do
    respond_to do |format|
      format.html do
        redirect_back fallback_location: root_path,
                      alert: I18n.t('errors.page_expired', default: 'This page had expired, so nothing was sent. Please try again.')
      end
      format.any { head :unprocessable_entity }
    end
  end

  def current_active_profile
    return nil unless current_user

    # Only ever pick one of the signed-in user's own, saved profiles. (A profile being
    # created can sit unsaved on the account while its form shows an error, so this
    # always asks the database rather than the in-memory list.)
    saved = current_user.marriage_profiles.where.not(id: nil)
    @current_active_profile = saved.find_by(id: session[:marriage_profile_id]) if session[:marriage_profile_id].present?
    @current_active_profile ||= current_user.main_marriage_profile
    session[:marriage_profile_id] = @current_active_profile.id if @current_active_profile
    @current_active_profile
  end

  def check_current_active_profile
    if current_active_profile.blank?
      flash[:notice] = 'Please complete your marriage profile first'
      redirect_to new_marriage_profile_path
    end
  end

  def check_preference
    return if current_active_profile.partner_preference.present?

    # A profile that was started but never finished (no preferences), while another
    # of the member's profiles is complete: open the complete one instead of an
    # empty Preference page. A profile made in the last day is still being set up.
    finished = current_user.main_marriage_profile
    if finished&.partner_preference.present? && current_active_profile.created_at < 1.day.ago
      session[:marriage_profile_id] = finished.id
      @current_active_profile = finished
      redirect_to dashboard_marriage_profile_path(finished)
      return
    end

    flash[:notice] = 'Please set preference'
    redirect_to new_partner_preference_path
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

  # Sending a Kobul (1st or 2nd) needs an 80% complete profile
  def require_profile_ready_for_kobul
    return if current_active_profile.nil? || current_active_profile.ready_for_kobul?

    flash[:warning] = "Complete at least #{MarriageProfile::KOBUL_MIN_COMPLETENESS}% of your profile to send a Kobul. " \
                      "Yours is #{current_active_profile.profile_completeness.to_i}% now: add your education, occupation, family and photos."
    redirect_to profile_info_marriage_profile_path(current_active_profile)
  end

  # The member's language: ?locale=bn|en (from the language switch) is remembered in a
  # cookie and on their account; otherwise the cookie, then the account, then English.
  # The admin panel always stays in English.
  LOCALES = %w[en bn].freeze

  def switch_locale(&action)
    I18n.with_locale(request_locale, &action)
  end

  def request_locale
    return :en if request.path.start_with?('/shefali007')

    chosen = params[:locale].to_s
    if LOCALES.include?(chosen)
      cookies.permanent[:bk_locale] = chosen
      current_user.update_column(:locale, chosen) if current_user && current_user.locale != chosen
      return chosen
    end
    from_cookie = cookies[:bk_locale].presence_in(LOCALES)
    # Remember it on the account too, so emails come in the same language
    current_user.update_column(:locale, from_cookie) if from_cookie && current_user && current_user.locale.blank?
    from_cookie || current_user&.locale.presence_in(LOCALES) || :en
  end

  def user_homepage(resource)
    main = resource.main_marriage_profile # saved profiles only
    if resource.created_for.present? && resource.other_as_matchmaker?
      main ? dashboard_marriage_profile_path(main) : new_marriage_profile_path
    elsif main.nil?
      new_marriage_profile_path
    elsif main.partner_preference.present?
      session[:marriage_profile_id] = main.id
      dashboard_marriage_profile_path(main)
    else
      session[:marriage_profile_id] = main.id
      new_partner_preference_path
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
