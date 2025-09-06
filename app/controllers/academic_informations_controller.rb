class AcademicInformationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_academic_info, only: [:edit, :update, :destroy]

  def new
    @academic_info = AcademicInformation.new
  end

  def create
    respond_to do |format|
      @academic_info = current_active_profile.academic_informations.build(academic_info_params)
      if @academic_info.save
        format.js { flash[:notice] = "Academic information added successfully." }
      else
        format.js { flash[:notice] = "Academic information failed to update. Try again" }
      end
    end
  end

  def edit

  end

  def update
    respond_to do |format|
      if @academic_info.update(academic_info_params)
        format.js { flash[:notice] = "Academic information updated successfully." }
      else
        format.js { flash[:notice] = "Academic information failed to update. Try again" }
      end
    end
  end

  def destroy
    respond_to do |format|
      if @academic_info.destroy
        format.js { flash[:notice] = "Academic information deleted successfully." }
      else
        format.js { flash[:notice] = "Academic information failed to delete. Try again" }
      end
    end
  end

  private

  def set_academic_info
    @academic_info = AcademicInformation.find_by(id: params[:id])
  end

  def academic_info_params
    params.require(:academic_information).permit!
  end
end
