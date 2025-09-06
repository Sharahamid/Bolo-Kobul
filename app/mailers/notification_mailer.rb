class NotificationMailer < ApplicationMailer
  def default_notification
    @notification = params[:notification]
    subject = if @notification.notifiable_type == 'CustomerSupport'
                'Customer Support Update'
              else
                'Bolokobul Update!'
              end

    mail(to: @notification.recipient.email,
         subject: subject)
  end

  def purchased_notification
    @notification = params[:notification]
    mail(to: @notification.recipient.email,
         subject: "Purchased notifications")
  end
end
