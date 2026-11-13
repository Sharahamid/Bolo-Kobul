# The member read the message from the team (shared/_team_message): mark it seen, then go
# where its button points (or stay on the page).
class TeamMessagesController < ApplicationController
  before_action :authenticate_user!

  def seen
    current_user.update_column(:admin_message_seen_at, Time.current) if current_user.admin_message_waiting?
    respond_to do |format|
      format.json { head :no_content }
      format.html { redirect_to(target_path || user_homepage(current_user)) }
    end
  end

  private

  def target_path
    profile = current_active_profile
    case params[:go]
    when 'photos' then profile ? dashboard_marriage_profile_path(profile) : nil
    when 'profile' then profile ? profile_info_marriage_profile_path(profile) : nil
    when 'verify'
      s = AssistedService.where('name ILIKE ?', '%verif%').order(:id).first || AssistedService.order(:id).first
      s ? assisted_service_path(s) : nil
    when 'support' then new_customer_support_path
    end
  rescue StandardError
    nil
  end
end
