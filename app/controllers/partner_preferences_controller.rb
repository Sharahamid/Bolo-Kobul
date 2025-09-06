class PartnerPreferencesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_partner_preference, only: [:show, :edit, :update]
  before_action :check_current_active_profile
  before_action :check_preference, except: [:new, :create]

  def index
    @preference = PartnerPreference.new
    render 'new'
  end

  def new
    @preference = PartnerPreference.new
  end

  def create
    @preference = current_active_profile.build_partner_preference(preference_params)
    if @preference.save
      flash[:success] = "Welcome! Your are in Bolokobul."
      redirect_to dashboard_marriage_profile_path(current_active_profile)
    else
      render 'new'
    end
  end

  def show
  end

  def edit
  end

  def update
    respond_to do |format|
      if @preference.update(preference_params)
        format.js { flash[:notice] = "Preference updated successfully." }
      else
        format.js { flash[:notice] = "#{@preference.errors.full_messages.first}" }
      end
    end
  end

  private
  def set_partner_preference
    @preference = PartnerPreference.find_by(id:params[:id])
  end

  def preference_params
    params.require(:partner_preference).permit(:family_type, :physical_status, :max_age, :min_age,:family_status, :max_height, :min_height, :max_inch, :min_inch, :highest_education_level, :family_values,:gender, blood_group: [], hometown: [], present_location: [], religion: [], marital_status: [])
  end
end
