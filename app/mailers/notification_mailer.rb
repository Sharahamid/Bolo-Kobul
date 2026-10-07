class NotificationMailer < ApplicationMailer
  def default_notification
    @notification = params[:notification]
    subject = if @notification.notifiable_type == 'CustomerSupport'
                t('email.notification.support_title')
              else
                t('email.notification.title')
              end

    mail(to: @notification.recipient.email,
         subject: subject)
  end

  def purchased_notification
    @notification = params[:notification]
    mail(to: @notification.recipient.email,
         subject: t('email.subject.receipt'))
  end
end
