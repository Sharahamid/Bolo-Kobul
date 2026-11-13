namespace :listings do
  desc 'Wedding Shopping List: email businesses whose listing ends in 14 days'
  task renewal_reminders: :environment do
    MarketPlace.send_renewal_reminders
  end
end
