# Unsubscribe link in the Friday matches email: works without logging in
class WeeklyEmailsController < ApplicationController
  # Mail apps' one-click unsubscribe posts here without a page or session
  skip_forgery_protection only: :unsubscribe
  before_action :find_user

  def unsubscribe
    @user&.update_column(:weekly_matches_email, false)
    return head(:ok) if request.post?

    render :show
  end

  def resubscribe
    @user&.update_column(:weekly_matches_email, true)
    render :show
  end

  private

  def find_user
    @user = WeeklyReminderService.user_from_token(params[:token])
    @token = params[:token]
  end
end
