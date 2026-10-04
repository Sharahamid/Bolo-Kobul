namespace :reminders do
  desc 'Friday reminder email to members away for 7 days (see WeeklyReminderService)'
  task weekly: :environment do
    puts "Weekly reminders sent to #{WeeklyReminderService.call} members"
  end
end
