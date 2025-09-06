# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  # before_action :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  def new
    redirect_to root_path
  end

  # POST /resource/sign_in
  def create
    unless params.has_key? :user
      respond_to do |format|
        flash[:danger] = 'Invalid request'
        format.js
        format.html { redirect_back(fallback_location: "/") }
      end
    end

    resource = User.find_for_database_authentication(email: params[:user][:login]) ||  User.find_for_database_authentication(phone_number: params[:user][:login])
    respond_to do |format|
      if resource.present? && resource.valid_password?(params[:user][:password])
        if resource.active_for_authentication?
          sign_in :user, resource
          flash[:success] = 'Signed in successfully.'
          format.js
          format.html { redirect_to after_sign_in_path_for(resource) }
        else
          format.js
          format.html { redirect_to show_verify_user_path(resource) }
        end
      else
        flash[:danger] = 'Invalid email or password.'
        format.js
        format.html { redirect_back(fallback_location: "/") }
      end
    end
  end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end
end
