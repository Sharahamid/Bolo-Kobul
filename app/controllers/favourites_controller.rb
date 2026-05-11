class FavouritesController < ApplicationController
  before_action :authenticate_user!

  def index
    @favourites = current_active_profile.favourite_profiles
  end

  def create
    @from_id = current_active_profile.id
    @to_id = params[:favourite_profile_id].to_i
    unless current_active_profile.favourite_profile_ids
         .include?(params[:favourite_profile_id].to_i)
      current_active_profile.favourites
        .create(favourite_profile_id: params[:favourite_profile_id])
    end
    flash[:notice] = "Added to your favourite list successfully."
    redirect_back(fallback_location: "/")
  end

  def remove
    @from_id = current_active_profile.id
    @to_id = params[:favourite_profile_id].to_i
    if params[:favourite_profile_id].present?
      Favourite.remove_from_favourite(params[:favourite_profile_id])
    end
    flash[:notice] = "Removed from your favourite list."
    redirect_back(fallback_location: "/")
  end

end
