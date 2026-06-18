class WeeklyReportMailer < ApplicationMailer
  def weekly_report
    @start_date = 1.week.ago.beginning_of_day
    @end_date = Time.current

    @successful_users = User.where(created_at: @start_date..@end_date).order(created_at: :desc)
    @honeypot_blocks = BlockedRegistrationAttempt.where(attempt_type: 'honeypot', created_at: @start_date..@end_date).order(created_at: :desc)
    @name_filter_blocks = BlockedRegistrationAttempt.where(attempt_type: 'name_filter', created_at: @start_date..@end_date).order(created_at: :desc)

    mail(to: "shara@bolokobul.com", subject: "Bolo Kobul Weekly Registration Report - #{Date.today.strftime('%B %d, %Y')}")
  end
end
