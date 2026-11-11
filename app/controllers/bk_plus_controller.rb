# BK+ membership page and the "who saved you" list
class BkPlusController < ApplicationController
  before_action :authenticate_user!, only: %i[saved_you viewed_you]

  def show
    @config = ButterflyConfig.last
    @member = current_user&.bk_plus?
    @saved_count = current_active_profile ? Favourite.where(favourite_profile_id: current_active_profile.id).count : 0
    @view_count = current_active_profile ? ProfileView.recent_for(current_active_profile).count : 0
  end

  # Members who saved this member to their favourites. Everyone sees the count;
  # BK+ members see who they are.
  def saved_you
    profile = current_active_profile
    return redirect_to(root_path) unless profile

    ids = Favourite.where(favourite_profile_id: profile.id).order(created_at: :desc).pluck(:marriage_profile_id)
    blocked = profile.blocked_friend_ids
    @saved_count = (ids - blocked).size
    @member = current_user.bk_plus?
    if @member
      found = MarriageProfile.where(id: ids - blocked).includes(:user).index_by(&:id)
      @profiles = (ids - blocked).map { |id| found[id] }.compact
      @profiles.each { |p| p.calculate_matching_percentage!(profile) }
    else
      @profiles = []
    end
  end

  # Members who viewed this member's profile in the last 30 days. Everyone sees the
  # count; BK+ members see who they are and when.
  def viewed_you
    profile = current_active_profile
    return redirect_to(root_path) unless profile

    views = ProfileView.recent_for(profile).to_a
    viewers = MarriageProfile.where(id: views.map(&:viewer_id)).includes(:user).index_by(&:id)
    views.select! { |v| (p = viewers[v.viewer_id]) && p.user && !p.user.deactivated && !profile.blocked_with?(p) && !p.blocked_with?(profile) }
    @view_count = views.size
    @member = current_user.bk_plus?
    @views = @member ? views : []
    @viewers = viewers
    @views.each { |v| viewers[v.viewer_id].calculate_matching_percentage!(profile) }
  end
end
