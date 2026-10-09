# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
every :day, at: '12:00am' do
  rake 'butterfly:return_after_7_days'
end

# Accounts whose 30-day deletion period has ended (3 am Bangladesh time)
every :day, at: '9:00 pm' do
  rake 'accounts:purge_deleted'
end

every :week do
  rake 'butterfly:clean_notifications'
end

every :week do
  rake 'butterfly:profile_incomplete_reminder'
end

every :week do
  rake 'butterfly:weekly_profile_view_summary'
end

# Learn more: http://github.com/javan/whenever
# The server clock is UTC: 4:00 am UTC is 10:00 am in Bangladesh
# Matches email and push: the task itself only sends every other Friday, spreading the
# emails until about 4 pm
every :friday, at: '4:00 am' do
  rake 'reminders:weekly'
end

# Registration report to the admin on the 15th and 30th (28th/29th in February);
# the task checks the date, so it can run on all four of these days
every '0 19 15,28,29,30 * *' do
  rake 'weekly_report:send'
end
