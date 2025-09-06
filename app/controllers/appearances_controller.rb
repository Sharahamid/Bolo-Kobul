class AppearancesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_appearance, only: [:edit, :update]

  def new
    @appearance = Appearance.new
  end

  def create
    respond_to do |format|
      @appearance = current_active_profile.build_appearance(appearance_params)
      if @appearance.save
        format.js { flash[:notice] = "Appearance added successfully." }
      else
        format.js { flash[:notice] = "Appearance failed to update. Try again" }
      end
    end
  end

  def edit

  end

  def update
    respond_to do |format|
      if  @appearance.update(appearance_params)
        format.js { flash[:notice] = "Appearance updated successfully." }
      else
        format.js { flash[:notice] = "Appearance failed to update. Try again" }
      end
    end
  end

  private

  def set_appearance
    @appearance = Appearance.find_by(id: params[:id])
  end

  def appearance_params
    params.require(:appearance).permit!
  end
end
