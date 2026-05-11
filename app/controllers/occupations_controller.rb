class OccupationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_occupation, only: [:edit, :update, :destroy]

  def new
    @occupation = Occupation.new
  end

  def create
    respond_to do |format|
      @occupation = current_active_profile.occupations.build(occupation_params)
      if @occupation.save
        format.js { flash[:notice] = "Occupation updated successfully." }
      else
        format.js { flash[:notice] = "Occupation failed to update. Try again" }
      end
    end
  end

  def edit

  end

  def update
    respond_to do |format|
      if @occupation.update(occupation_params)
        format.js { flash[:notice] = "Occupation updated successfully." }
      else
        format.js { flash[:notice] = "Occupation failed to update. Try again" }
      end
    end
  end

  def destroy
    respond_to do |format|
      if @occupation.destroy
        format.js { flash[:notice] = "Occupation deleted successfully." }
      else
        format.js { flash[:notice] = "Occupation failed to delete. Try again" }
      end
    end
  end

  private

  def set_occupation
    @occupation = Occupation.find_by(id: params[:id])
  end

  def occupation_params
    params.require(:occupation).permit!
  end
end
