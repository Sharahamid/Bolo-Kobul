class NotificationMailer < ApplicationMailer
  def default_notification
    @notification = params[:notification]
    subject = if @notification.notifiable_type == 'CustomerSupport'
                'Your support request has been updated'
              else
                'You have a new update from Bolo Kobul'
              end

    mail(to: @notification.recipient.email,
         subject: subject)
  end

  def purchased_notification
    @notification = params[:notification]
    mail(to: @notification.recipient.email,
         subject: "Your purchase was successful — here is your receipt")
  end
end
