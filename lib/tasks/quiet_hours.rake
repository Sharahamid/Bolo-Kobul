namespace :quiet_hours do
  desc 'Send the phone notifications and texts held overnight (10 pm - 8 am Bangladesh time)'
  task release: :environment do
    result = QuietHours.release!
    puts "Released #{result[:pushes]} phone notification(s) and #{result[:texts]} text(s)"
  end
end
