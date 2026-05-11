class MarriageInformationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_marriage_info, only: [:edit, :update]

  def new
    @marriage_info = MarriageInformation.new
  end

  def create
    respond_to do |format|
      @marriage_info = current_active_profile.build_marriage_information(marriage_info_params)
      if @marriage_info.save
        format.js { flash[:notice] = "Marriage Information added successfully." }
      else
        format.js { flash[:notice] = "Marriage Information failed to update. Try again" }
      end
    end
  end

  def edit

  end

  def update
    respond_to do |format|
      if  @marriage_info.update(marriage_info_params)
        format.js { flash[:notice] = "Marriage Information updated successfully." }
      else
        format.js { flash[:notice] = "#{@marriage_info.errors.full_messages.first}" }
      end
    end
  end

  private

  def set_marriage_info
    @marriage_info = MarriageInformation.find_by(id: params[:id])
  end

  def marriage_info_params
    params.require(:marriage_information).permit!
  end
end
