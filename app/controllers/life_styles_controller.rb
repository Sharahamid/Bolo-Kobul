class LifeStylesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_life_style, only: [:edit, :update]

  def new
    @life_style = LifeStyle.new
  end

  def create
    respond_to do |format|
      @life_style = current_active_profile.build_life_style(life_style_params)
      if @life_style.save
        format.js { flash[:notice] = 'Life Style added successfully.' }
      else
        format.js { flash[:notice] = "#{@life_style.errors.full_messages.first}"}
      end
    end
  end

  def edit

  end

  def update
    respond_to do |format|
      if @life_style.update(life_style_params)
        format.js { flash[:notice] = 'Life Style updated successfully.' }
      else
        format.js { flash[:notice] = "#{@life_style.errors.full_messages.first}" }
      end
    end
  end

  private

  def set_life_style
    @life_style = LifeStyle.find_by(id: params[:id])
  end

  def life_style_params
    params.require(:life_style).permit(:food_habits, :drinker, :smoker, :specific_habits, dress_style: [], living_with: [])
  end
end
