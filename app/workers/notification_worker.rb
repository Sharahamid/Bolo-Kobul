class NotificationWorker
  include Sidekiq::Worker

  def perform(notification_id)
    puts "############### Notifying... notification_id: #{notification_id}"
    notification = Notification.find_by(id: notification_id)
    notification.send_sms if notification.will_sms?
    notification.send_email if notification.will_email?
  end
end
