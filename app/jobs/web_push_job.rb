# Sends a notification to every device a user has enabled notifications on
class WebPushJob < ApplicationJob
  queue_as :default

  def perform(user_id, payload)
    return unless WebPushService.configured?

    PushSubscription.where(user_id: user_id).find_each do |subscription|
      WebPushService.deliver(subscription, payload)
    end
  end
end
