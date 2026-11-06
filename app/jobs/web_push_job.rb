# Sends a notification to every device a user has enabled notifications on
class WebPushJob < ApplicationJob
  queue_as :default

  def perform(user_id, payload)
    return unless WebPushService.configured?

    # One notification per device: if a browser holds more than one sign-up (an old one
    # from www.bolokobul.com, say), only the newest is used
    PushSubscription.where(user_id: user_id).order(updated_at: :desc).to_a
                    .uniq { |subscription| subscription.user_agent.presence || subscription.id }
                    .each { |subscription| WebPushService.deliver(subscription, payload) }
  end
end
