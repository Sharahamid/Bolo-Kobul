# Sends a notification to every device a user has enabled notifications on
class WebPushJob < ApplicationJob
  queue_as :default

  # Sends to every device the member has turned notifications on for. Addresses the
  # phone has thrown away are removed automatically (WebPushService, on 404/410).
  # released = true when it is sent at 8 am after waiting overnight (QuietHours)
  def perform(user_id, payload, released = false)
    return unless WebPushService.configured?
    # 10 pm - 8 am Bangladesh time: keep it for the morning (a test the member asks for goes now)
    return if !released && !payload.to_h['now'] && QuietHours.hold_push?(user_id, payload)

    subscriptions = PushSubscription.where(user_id: user_id).to_a
    results = subscriptions.map { |subscription| WebPushService.deliver(subscription, payload) }
    Rails.logger.info("[WebPush] user #{user_id}: #{subscriptions.size} device(s) #{results.tally.inspect}")
  end

end
