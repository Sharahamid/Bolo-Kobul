class AdvertiserProfilesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_advertiser_profile, only: [:show, :edit, :update, :destroy ]

  def new
    @advertiser_profile = AdvertiserProfile.new
  end

  def create
    advertiser_profile = current_user.build_advertiser_profile(advertiser_params)
    if advertiser_profile.save!
      flash["success"] = 'Welcome! You created advertiser profile successfully.'
      redirect_to advertiser_profile_path(advertiser_profile)
    else
      flash[:danger] = "Failed! #{advertiser_profile.errors.full_messages.first}"
      redirect_to new_advertiser_profile_path
    end
  end

  def show
    redirect_to @advertiser_profile.user.marriage_profiles.first || current_active_profile || root_path
  end

  private
  def advertiser_params
    params.require(:advertiser_profile).permit!
  end

  def set_advertiser_profile
    @advertiser_profile = AdvertiserProfile.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render file: "#{Rails.root}/public/404", layout: false, status: :not_found
  end
end
