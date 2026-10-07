# Registration report for the admin on the 15th and the 30th of every month
# (the last day in February), covering the time since the previous report
class WeeklyReportMailer < ApplicationMailer
  SEND_HOUR_UTC = 19

  def self.report_day?(date = Date.current)
    date.day == 15 || date.day == [30, date.end_of_month.day].min
  end

  # The report day before the given one
  def self.previous_report_day(date)
    return Date.new(date.year, date.month, 15) unless date.day == 15

    previous = date.prev_month
    Date.new(previous.year, previous.month, [30, previous.end_of_month.day].min)
  end

  def weekly_report
    @end_date = Time.current
    @start_date = self.class.previous_report_day(Date.current).in_time_zone('UTC').change(hour: SEND_HOUR_UTC)

    @successful_users = User.where(created_at: @start_date..@end_date).order(created_at: :desc)
    @honeypot_blocks = BlockedRegistrationAttempt.where(attempt_type: 'honeypot', created_at: @start_date..@end_date).order(created_at: :desc)
    @name_filter_blocks = BlockedRegistrationAttempt.where(attempt_type: 'name_filter', created_at: @start_date..@end_date).order(created_at: :desc)

    mail(to: "shara@bolokobul.com", subject: "Bolo Kobul Registration Report - #{Date.today.strftime('%B %d, %Y')}")
  end

  private

  # Emails to the Bolo Kobul team are always in English
  def locale_recipient
    nil
  end
end
