class CulturalValuesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_cultural_values, only: [:edit, :update]

  def new
    @cultural_value = CulturalValue.new
  end

  def create
    respond_to do |format|
      @cultural_value = current_active_profile.build_cultural_value(cultural_value_params)
      if @cultural_value.save
        format.js { flash[:notice] = "Cultural Value added successfully." }
      else
        format.js { flash[:notice] = "#{@cultural_value.errors.full_messages.first}"}
      end
    end
  end

  def edit

  end

  def update
    respond_to do |format|
      if @cultural_value.update(cultural_value_params)
        format.js { flash[:notice] = "Cultural Value updated successfully." }
      else
        format.js { flash[:notice] = "#{@cultural_value.errors.full_messages.first}"}
      end
    end
  end

  private

  def set_cultural_values
    @cultural_value = CulturalValue.where(marriage_profile_id: owned_profile_ids).find(params[:id])
  end

  def cultural_value_params
    params.require(:cultural_value).permit!.except(:marriage_profile_id)
  end
end
