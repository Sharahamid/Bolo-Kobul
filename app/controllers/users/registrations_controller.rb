# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  # Bots: at most SIGNUP_LIMIT_PER_HOUR sign-ups an hour from one internet address, and a
  # form sent sooner than SIGNUP_MIN_SECONDS after it was shown is treated as a bot
  SIGNUP_LIMIT_PER_HOUR = ENV.fetch('SIGNUP_LIMIT_PER_HOUR', 10).to_i
  SIGNUP_MIN_SECONDS = ENV.fetch('SIGNUP_MIN_SECONDS', 3).to_i

  rate_limit to: SIGNUP_LIMIT_PER_HOUR, within: 1.hour, only: :create, with: lambda {
    Rails.logger.warn("[BOT BLOCKED - Rate limit] #{request.remote_ip}")
    BlockedRegistrationAttempt.record('rate_limit', name: params.dig(:user, :name), email: params.dig(:user, :email),
                                                    phone: params.dig(:user, :phone_number), ip: request.remote_ip)
    flash[:danger] = 'Too many sign-ups from this connection. Please try again in an hour.'
    redirect_to root_path
  }

  def self.form_shown_token
    Rails.application.message_verifier(:signup_form).generate(Time.current.to_i)
  end

  # before_action :configure_sign_up_params, only: [:create]
  # before_action :configure_account_update_params, only: [:update]

  # GET /resource/sign_up
  # def new
  #   super
  #   #redirect_to root_path
  # end

  # POST /resource
  def create
    if params[:user][:website].present?
      Rails.logger.warn("[BOT BLOCKED - Honeypot] #{Time.current} | IP: #{request.remote_ip} | Name: #{params.dig(:user, :name)} | Email: #{params.dig(:user, :email)}")
      BlockedRegistrationAttempt.create(name: params.dig(:user, :name), email: params.dig(:user, :email), phone: params.dig(:user, :phone_number), attempt_type: "honeypot", ip_address: request.remote_ip)
      redirect_to root_path, notice: "Registration successful."
      return
    end
    shown_at = Rails.application.message_verifier(:signup_form).verified(params.dig(:user, :form_shown).to_s) rescue nil
    if shown_at.nil?
      # A page loaded before this check existed, or a script posting directly
      flash[:warning] = 'Please fill in the form again.'
      redirect_to root_path
      return
    end
    if Time.current.to_i - shown_at.to_i < SIGNUP_MIN_SECONDS
      Rails.logger.warn("[BOT BLOCKED - Too fast] #{Time.current} | IP: #{request.remote_ip} | Name: #{params.dig(:user, :name)} | Email: #{params.dig(:user, :email)}")
      BlockedRegistrationAttempt.create(name: params.dig(:user, :name), email: params.dig(:user, :email), phone: params.dig(:user, :phone_number), attempt_type: 'too_fast', ip_address: request.remote_ip)
      # Nothing is sent. A person (e.g. using autofill) just presses Register again;
      # the form comes back filled in, with a fresh time
      build_resource(sign_up_params)
      clean_up_passwords(resource)
      @user = resource
      flash.now[:warning] = 'Please check your details and press Register again.'
      render 'home/landing'
      return
    end

    remove_abandoned_sign_ups
    build_resource(sign_up_params)

    if resource.save
      session[:ga_event] = 'sign_up' # reported to Google Analytics on the next page
      referral_code = resource.refferel_promo_code.presence || session[:pending_referral_code]
      if referral_code.present?
        resource.earn_bf_by_reference(referral_code)
        session.delete(:pending_referral_code)
      end
      if resource.active_for_authentication?
        set_flash_message :info, :signed_up if is_navigational_format?
        sign_in(resource_name, resource)
        respond_with resource, :location => redirect_location(resource_name, resource)
      else
        code_sent = resource.send_otp
        set_flash_message :info, :"signed_up_but_#{resource.inactive_message}", :reason => resource.inactive_message.to_s if is_navigational_format?
        unless code_sent
          flash.delete(:info)
          flash[:warning] = "Your account is created, but we couldn't send your verification code just now. Please tap Resend Code in a minute."
        end
        expire_data_after_sign_in!
        respond_with resource, :location => after_inactive_sign_up_path_for(resource)
      end
    else
      record_refused_sign_up
      clean_up_passwords(resource)
      #flash[:danger] = resource.errors.full_messages.first
      #redirect_to root_path(errors: resource.errors.messages, user: resource.attributes) # HERE IS THE PATH YOU WANT TO CHANGE
      @user = resource
      render 'home/landing'
    end
  end
  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  # def update
  #   super
  # end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_up_params
  #   devise_parameter_sanitizer.permit(:sign_up, keys: [:attribute])
  # end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
  # end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # A sign-up that never got as far as entering the code (no code arrived, the page was
  # closed, or the form was sent twice) would otherwise block the same email or number
  # with "has already been taken". Starting again replaces it, as long as it was never
  # verified and has nothing in it.
  def remove_abandoned_sign_ups
    email = params.dig(:user, :email).to_s.strip.downcase
    phone = params.dig(:user, :phone_number).to_s.strip
    unverified = User.where(verified: [false, nil])
    ids = []
    ids += unverified.where('LOWER(email) = ?', email).pluck(:id) if email.present?
    ids += PhoneNumber.matching(unverified, phone).pluck(:id) if phone.present?
    User.where(id: ids.uniq).find_each do |user|
      next if user.marriage_profiles.exists? || user.orders.exists?

      Rails.logger.info("[sign-up] replacing unverified sign-up #{user.id} (created #{user.created_at})")
      user.destroy
    end
  end

  # Sign-ups turned away by the name or phone checks go in the registration report, so a
  # real person who was refused can be spotted (other mistakes, e.g. a short password, do not)
  def record_refused_sign_up
    details = { name: resource.name, email: resource.email, phone: params.dig(:user, :phone_number), ip: request.remote_ip }
    if resource.errors[:name].any? { |m| m.include?('real name') }
      BlockedRegistrationAttempt.record('name_check', **details)
    elsif resource.errors[:phone_number].any? { |m| m != I18n.t('errors.messages.taken') }
      BlockedRegistrationAttempt.record('phone_check', **details)
    end
  end

  def after_inactive_sign_up_path_for(resource)
    show_verify_user_path(resource)
  end
end
