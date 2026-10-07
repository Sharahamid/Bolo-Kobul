# Saving, running and deleting a member's saved searches (search page)
class SavedSearchesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_saved_search, only: [:run, :destroy]

  def create
    profile = current_user.marriage_profiles.friendly.find(params[:marriage_profile_id])
    criteria = SavedSearch.criteria_from(params)
    saved = profile.saved_searches.build(name: params[:name].to_s.strip.first(60), criteria: criteria, last_run_at: Time.current)
    if saved.save
      flash[:notice] = t('saved_search.saved', name: saved.name)
    else
      flash[:warning] = saved.errors.full_messages.first
    end
    redirect_to search_marriage_profile_path(profile, criteria)
  end

  # Opens the search again; profiles that joined after this moment count as new next time
  def run
    @saved_search.update_column(:last_run_at, Time.current)
    redirect_to search_marriage_profile_path(@saved_search.marriage_profile, @saved_search.criteria)
  end

  def destroy
    profile = @saved_search.marriage_profile
    @saved_search.destroy
    flash[:notice] = t('saved_search.deleted')
    redirect_to search_page_marriage_profile_path(profile)
  end

  private

  def set_saved_search
    @saved_search = SavedSearch.where(marriage_profile_id: current_user.marriage_profiles.select(:id)).find(params[:id])
  end
end
