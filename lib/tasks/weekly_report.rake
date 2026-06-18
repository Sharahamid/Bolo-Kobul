namespace :weekly_report do
  desc "Send weekly registration report email"
  task send: :environment do
    WeeklyReportMailer.weekly_report.deliver_now
    puts "Weekly report sent."
  end
end
