# Saves or removes the signed-in user's notification subscription for this device
class PushSubscriptionsController < ApplicationController
  before_action :authenticate_user!

  def create
    keys = params.require(:keys)
    subscription = PushSubscription.find_or_initialize_by(endpoint: params.require(:endpoint))
    subscription.assign_attributes(
      user: current_user,
      p256dh: keys.require(:p256dh),
      auth: keys.require(:auth),
      user_agent: request.user_agent.to_s[0, 255]
    )
    if subscription.save
      head :created
    else
      head :unprocessable_entity
    end
  end

  def destroy
    current_user.push_subscriptions.where(endpoint: params[:endpoint]).destroy_all
    head :no_content
  end
end
