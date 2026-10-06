namespace :weekly_report do
  desc "Registration report email on the 15th and 30th of the month (last day in February)"
  task send: :environment do
    if WeeklyReportMailer.report_day? || ENV['FORCE'] == '1'
      WeeklyReportMailer.weekly_report.deliver_now
      puts "Registration report sent."
    else
      puts "Not a report day (reports go out on the 15th and 30th)."
    end
  end
end
