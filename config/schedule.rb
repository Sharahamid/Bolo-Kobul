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
every :friday, at: '7:00 pm' do
  rake 'weekly_report:send'
end
