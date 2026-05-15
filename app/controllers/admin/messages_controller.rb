class Admin::MessagesController < ApplicationController
  before_action :authenticate_admin_user!

  def send_message
    user = User.find_by(email: params[:email])
    if user.nil?
      render json: { success: false, error: "User not found with that email." } and return
    end
    user.notifications.create(
      content: params[:message],
      notifiable: user
    )
    render json: { success: true }
  rescue => e
    render json: { success: false, error: e.message }
  end
end
