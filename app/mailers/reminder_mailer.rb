class ReminderMailer < ApplicationMailer
  # Friday matches email - see WeeklyReminderService
  def weekly
    @receiver = params[:user]
    @reminder = params[:reminder]
    @unsubscribe_url = Rails.application.routes.url_helpers.weekly_email_unsubscribe_url(
      token: WeeklyReminderService.unsubscribe_token(@receiver), host: WeeklyReminderService::HOST, protocol: 'https'
    )
    # One-click unsubscribe button in Gmail and other mail apps
    headers['List-Unsubscribe'] = "<#{@unsubscribe_url}>"
    headers['List-Unsubscribe-Post'] = 'List-Unsubscribe=One-Click'
    mail(to: @receiver.email, subject: @reminder[:subject])
  end
end
