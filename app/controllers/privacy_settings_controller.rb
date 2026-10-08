class PrivacySettingsController < ApplicationController
  before_action :authenticate_user!
  before_action :check_current_active_profile, :check_preference
  before_action :set_privacy_setting, only: [:show, :toggle_update]

  def index
    @text_alert_butterflies = ButterflyConfig.last.present? ?
                              ButterflyConfig.last.text_alert_butterflies : 0
    @adv_search_butterflies = ButterflyConfig.last.present? ?
                                ButterflyConfig.last.adv_search_butterflies : 0
  end

  def show
  end

  def toggle_update
    # Only the privacy columns can be switched, never any other method named in the request
    column = PrivacySetting.defined_enums.keys.find { |name| name == params[:privacy_column].to_s }
    return head(:bad_request) unless column

    if @privacy_setting.public_send("#{column}_public?")
      @privacy_setting.public_send("#{column}_private!")
    else
      @privacy_setting.public_send("#{column}_public!")
    end
    redirect_back fallback_location: root_path, notice: 'Privacy Updated Successfully.'
  end

  private

  def set_privacy_setting
    @privacy_setting = PrivacySetting.where(marriage_profile_id: owned_profile_ids).find(params[:id])
  end

  def privacy_setting_params
    params.require(:privacy_setting).permit(:current_occupation, :date_of_birth, :family_status, :family_type, :family_values, :gender, :height_ft, :highest_education_level, :physical_status)
  end

end
