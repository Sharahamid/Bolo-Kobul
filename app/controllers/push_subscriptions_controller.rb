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
      user_agent: request.user_agent.to_s[0, 255],
      updated_at: Time.current
    )
    if subscription.save
      # When the phone replaces its notification address, forget the old one.
      # (Previously every other sign-up with the same browser name was removed, but
      # all Android phones on the same Chrome version report the same name, so a
      # second phone, or the app and the browser, could silently knock each other out.)
      previous = params[:previous_endpoint].to_s
      if previous.present? && previous != subscription.endpoint
        current_user.push_subscriptions.where(endpoint: previous).delete_all
      end
      head :created
    else
      head :unprocessable_entity
    end
  end

  # "Send test notification" on the notifications page
  def test
    return head(:not_found) unless WebPushService.configured? && current_user.push_subscriptions.exists?

    WebPushJob.perform_later(current_user.id, {
      'title' => 'Bolo Kobul',
      'body' => t('push.test'),
      'url' => '/users/notifications',
      'tag' => "test-#{Time.current.to_i}"
    })
    head :accepted
  end

  def destroy
    current_user.push_subscriptions.where(endpoint: params[:endpoint]).destroy_all
    head :no_content
  end
end
