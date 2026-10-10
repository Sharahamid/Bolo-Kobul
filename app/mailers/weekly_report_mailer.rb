# Registration report for the admin on the 15th and the 30th of every month
# (the last day in February), covering the time since the previous report
class WeeklyReportMailer < ApplicationMailer
  SEND_HOUR_UTC = 19

  # The schedule runs at 19:00 UTC, which is already the next day in Bangladesh (the site's
  # time zone), so report days are counted on the UTC calendar
  def self.today
    Time.now.utc.to_date
  end

  def self.report_day?(date = today)
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
    from_day = self.class.previous_report_day(self.class.today)
    @start_date = Time.utc(from_day.year, from_day.month, from_day.day, SEND_HOUR_UTC).in_time_zone
    @period = "#{from_day.strftime('%B %d')} to #{self.class.today.strftime('%B %d, %Y')}"

    @successful_users = User.where(created_at: @start_date..@end_date).order(created_at: :desc)
    blocked = BlockedRegistrationAttempt.where(created_at: @start_date..@end_date).order(created_at: :desc).to_a
    # Ones that could be a real person first, for checking; the rest are almost certainly bots
    @to_check, @bots = blocked.partition(&:maybe_real_person?)
    @counts = blocked.group_by(&:reason).transform_values(&:size)

    mail(to: "shara@bolokobul.com", subject: "Bolo Kobul Registration Report - #{self.class.today.strftime('%B %d, %Y')}")
  end

  private

  # Emails to the Bolo Kobul team are always in English
  def locale_recipient
    nil
  end
end
