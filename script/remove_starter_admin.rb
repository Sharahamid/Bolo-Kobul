# Removes the starter admin login (admin@example.com) that early setup created.
# Check only (changes nothing):  RAILS_ENV=production bundle exec rails runner script/remove_starter_admin.rb
# Remove it:                     RAILS_ENV=production bundle exec rails runner script/remove_starter_admin.rb remove
STARTER = 'admin@example.com'.freeze

puts 'Admin logins on the site:'
AdminUser.order(:id).each do |a|
  puts "  #{a.id}. #{a.email}  (role: #{a.try(:role)})#{'   <- starter login' if a.email.casecmp?(STARTER)}"
end

starter = AdminUser.where('LOWER(email) = ?', STARTER).first
unless starter
  puts "\nGood: there is no starter login (#{STARTER}). Nothing to do."
  exit
end

others = AdminUser.where.not(id: starter.id)
if others.none?
  puts "\nNOT removed: #{STARTER} is the only admin login. Add your own admin first, then run this again."
  exit
end

if ARGV.first == 'remove'
  starter.destroy!
  puts "\nDone: #{STARTER} has been removed. #{others.count} admin login(s) remain."
else
  puts "\nThe starter login #{STARTER} exists. To remove it, run the same command with the word remove at the end."
end
