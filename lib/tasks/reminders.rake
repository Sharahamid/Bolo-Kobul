namespace :reminders do
  desc 'Friday reminder email + SMS to every active member (see WeeklyReminderService)'
  task weekly: :environment do
    puts "Weekly reminders sent to #{WeeklyReminderService.call} members"
  end
end
