class UsersController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show_verify, :verify, :resend]
  before_action :set_user, only: [:show_verify, :verify, :resend]

  def index
    @user = User.new
    render 'home/landing'
  end

  def show_verify
  end

  def verify
    if @user.otp == params[:token]
      @user.update(verified: true)
      UserAccountMailer.with(user: @user).registration.deliver_later
      sign_in(:user, @user)
      redirect_to after_sign_in_path_for(@user)
    else
      redirect_to show_verify_user_path(@user), notice: 'Incorrect code, please try again'
    end
  end

  def resend
    @user.send_otp
    redirect_to show_verify_user_path(@user), notice: 'Verification code re-sent'
  end

  def notifications
    @notifications = current_user.notifications
  end

  def mobile_notifications
    @notifications = current_user.notifications
  end

  def mark_notification_read
    @notification = current_user.notifications.find_by(id: params[:notification_id])

    @notification && @notification.mark_read
    @notifications = current_user.notifications.order(:is_read, created_at: :desc)
    @count = @notifications.unread.count > 0 ? @notifications.unread.count : nil
  end

  def change_password
    @user = current_user
  end

  def update_password
    @user = User.find_by(id: current_user.id)
    if @user.update_with_password(password_params)
      sign_in @user, :bypass => true
      redirect_back fallback_location: root_path, notice: 'Password Changed Successfully'
    else
      redirect_back fallback_location: root_path, notice: "#{@user.errors.full_messages.first}"
    end
  end

  def deactivate_account
    @user = User.find_by(id: current_user.id)
    if @user&.update(deactivated: true)
      redirect_back fallback_location: root_path, notice: 'Deactivated Successfully'
    else
      redirect_back fallback_location: root_path, notice: "#{@user.errors.full_messages.first}"
    end
  end

  def activate_account
    @user = User.find_by(id: current_user.id)
    if @user&.update(deactivated: false)
      redirect_back fallback_location: root_path, notice: 'Activated Successfully'
    else
      redirect_back fallback_location: root_path, notice: "#{@user.errors.full_messages.first}"
    end
  end

  def toggle_text_alert
    @user = User.find_by(id: current_user.id)
    if @user.text_alert == "off"
      @text_alert_butterflies = ButterflyConfig.last.present? ?
                                    ButterflyConfig.last.text_alert_butterflies : 0
      if @user.butterfly_number.to_i >= @text_alert_butterflies
        @user.butterfly_number = @user.butterfly_number - @text_alert_butterflies
        @user.text_alert = "on"
        if @user.save
          redirect_to privacy_settings_path(butterfly: "animate"),
                      notice: "Text alert settings successfully turned 'On' with Butterflies"
        else
          redirect_back fallback_location: root_path,
                        notice: "#{@user.errors.full_messages.first}"
        end
      else
        redirect_to new_order_path,
                      notice: "You don't have enough Butterflies for this!"
      end
    else
      @user.text_alert = "off"
      if @user.save
        redirect_to privacy_settings_path,
                    notice: "Text alert settings successfully turned 'Off'"
      else
        redirect_back fallback_location: root_path,
                      notice: "#{@user.errors.full_messages.first}"
      end
    end
  end

  def toggle_advanced_search
    @user = User.find_by(id: current_user.id)
    if @user.advanced_search == "disabled"
      @adv_search_butterflies = ButterflyConfig.last.present? ?
                                    ButterflyConfig.last.adv_search_butterflies : 0
      if @user.butterfly_number.to_i >= @adv_search_butterflies
        @user.butterfly_number = @user.butterfly_number - @adv_search_butterflies
        @user.advanced_search = "enabled"
        if @user.save
          redirect_to privacy_settings_path(butterfly: "animate"),
                      notice: "Advanced Search settings successfully 'Enabled' with Butterflies"
        else
          redirect_back fallback_location: root_path,
                        notice: "#{@user.errors.full_messages.first}"
        end
      else
        redirect_to new_order_path,
                      notice: "You don't have enough Butterflies for this!"
      end
    else
      @user.advanced_search = "disabled"
      if @user.save
        redirect_to privacy_settings_path,
                    notice: "Advanced Search settings successfully 'Disabled'"
      else
        redirect_back fallback_location: root_path,
                      notice: "#{@user.errors.full_messages.first}"
      end
    end
  end


  def update_referral_code
    user = current_user
    earning_bf_response = params[:user][:refferel_promo_code].present? ?
                              user.earn_bf_by_reference(params[:user][:refferel_promo_code]) :
                              'Empty promo code is not allowed'
    redirect_back fallback_location: root_path, notice: earning_bf_response
  end

  private

  def password_params
    params.require(:user).permit(:password, :password_confirmation, :current_password)
  end

  def set_user
    @user = User.find_by(slug: params[:id])
  end
end
