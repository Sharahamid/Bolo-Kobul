# Sends a notification to every device a user has enabled notifications on
class WebPushJob < ApplicationJob
  queue_as :default

  # Sends to every device the member has turned notifications on for. Addresses the
  # phone has thrown away are removed automatically (WebPushService, on 404/410).
  def perform(user_id, payload)
    return unless WebPushService.configured?

    subscriptions = PushSubscription.where(user_id: user_id).to_a
    results = subscriptions.map { |subscription| WebPushService.deliver(subscription, payload) }
    Rails.logger.info("[WebPush] user #{user_id}: #{subscriptions.size} device(s) #{results.tally.inspect}")
  end

end
