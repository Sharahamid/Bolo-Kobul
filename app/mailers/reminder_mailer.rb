class ReminderMailer < ApplicationMailer
  # Friday reminder - see WeeklyReminderService
  def weekly
    @receiver = params[:user]
    @reminder = params[:reminder]
    mail(to: @receiver.email, subject: @reminder[:subject])
  end
end
