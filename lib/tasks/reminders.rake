namespace :reminders do
  desc 'Every other Friday: matches email and push for members away for 14 days (see WeeklyReminderService). Emails are spread over 6 hours.'
  task weekly: :environment do
    if WeeklyReminderService.sending_week? || ENV['FORCE'] == '1'
      puts "Match reminders sent to #{WeeklyReminderService.call} members"
    else
      puts 'Not a sending week (reminders go out every other Friday)'
    end
  end
end
