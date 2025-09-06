class HobbiesAndInterestsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_hobbies_and_interest, only: [:edit, :update]

  def new
    @hobbies_and_interest = HobbiesAndInterest.new
  end

  def create
    respond_to do |format|
      @hobbies_and_interest = current_active_profile.build_hobbies_and_interest(hobbies_and_interest_params)
      if @hobbies_and_interest.save
        format.js { flash[:notice] = "Hobbies and interest added successfully." }
      else
        format.js { flash[:notice] = "#{@hobbies_and_interest.errors.full_messages.first}" }
      end
    end
  end

  def edit

  end

  def update
    respond_to do |format|
      if @hobbies_and_interest.update(hobbies_and_interest_params)
        format.js { flash[:notice] = "Hobbies and interest updated successfully." }
      else
        format.js { flash[:notice] = "#{@hobbies_and_interest.errors.full_messages.first}" }
      end
    end
  end

  private

  def set_hobbies_and_interest
    @hobbies_and_interest = HobbiesAndInterest.find_by(id: params[:id])
  end

  def hobbies_and_interest_params
    params.require(:hobbies_and_interest).permit(:specific_entertainment, :favourite_song, :favourite_book,  hobby: [], interest: [], favourite_sports_show: [], fitness_activity: [], cuisine: [], read: [], favourite_movie: [], favourite_tv_show: [], music: [], travel: [])
  end
end
