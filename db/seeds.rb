# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
#

# puts 'Creating privacy settings for marriage profiles'
# PrivacySetting.delete_all
# MarriageProfile.all.each do |profile|
#   privacy_setting=  profile.create_privacy_setting
# end

puts 'Issue types of customer supports inserting.....'
File.open(File.join(Rails.root, "/db/seeds/customer_supports/issue_types.txt"), "r") do |f|
  f.each_line do |line|
    IssueType.where(:name => line.strip).first_or_create
  end
end

puts "Contact Bolokobul dummy text....."
Contact.first_or_create(heading: "Does marriage mean family pressure,
 additional stress and fear of not finding the right one for you? Not anymore.",
    content: "Bolo Kobul is the one stop solution to help you find you r soulmate
while ensuring your data is secured.

At Bolo Kobul, you can flip through our database of potential
 matches for you, send butterflies to your chosen one, and if
your chosen one, chooses you too, you can view each other’s biodata,
 chat online and proceed to meet face-to-face. Once you have found your
soulmate, select from the exclusive package list of Bolo Kobul’s
 Directory of event management companies, photographers, caterers,
make-up artists, venues, etc. to organize your special day,
just as you dreamt, within your budget.

Focused on being a platform to connect user with proper
Control and Security with suitable prospects using backend
 algorithms, Bolo Kobul ensures your weddings decisions, are solely yours to make at all times.

From finding the perfect life partner, to arrangements for
 your big day, Bolo Kobul guides you throughout your wedding journey.", address: 'Bolokobul Head office', contact:'bolokobul@hotmail.com')


Dir[File.join(Rails.root, 'db', 'seeds', '*.rb')].sort.each { |seed| load seed }

puts "Inserting Countries ..."
File.open(File.join(Rails.root, "/db/seeds/countries/countries.txt"), "r") do |f|
  f.each_line do |line|
    Country.where(:name => line.strip).first_or_create
  end
end

puts "Inserting Divisions of Bangladesh ..."
File.open(File.join(Rails.root, "/db/seeds/divisions/bd_divisions.txt"), "r") do |f|
  f.each_line do |line|
    Division.where(:name => line.strip, country_id: 14).first_or_create
  end
end

puts "Inserting Districts of Bangladesh ..."
Division.all.each do |division|
  File.open(File.join(Rails.root, "/db/seeds/districts/#{division.id}.txt"), "r") do |f|
    f.each_line do |line|
      District.where(:name => line.strip, division_id: division.id).first_or_create
    end
  end
end

puts "Inserting Organizations ..."
File.open(File.join(Rails.root, "/db/seeds/organizations/industry.txt"), "r") do |f|
  f.each_line do |line|
    Organization.where(:name => line.strip).first_or_create
  end
end

puts "Inserting Designations ..."
File.open(File.join(Rails.root, "/db/seeds/designations/designation.txt"), "r") do |f|
  f.each_line do |line|
    Designation.where(:name => line.strip).first_or_create
  end
end

AdminUser.first_or_create(email: 'admin@example.com', password: 'password', password_confirmation: 'password')

# puts "Slugifying... for Models(User, MarriageProfile, Blog) with friendly ID (If Models got big please do it manually)"
#
# User.find_each do |obj|
#   obj.save(validate: false)
# end
#
# MarriageProfile.find_each do |obj|
#   obj.save(validate: false)
# end
#
# Blog.find_each do |obj|
#   obj.save(validate: false)
# end

puts "Creating Default Configurations..."
ButterflyConfig.first_or_create

# puts "Generating referral code for all previous users..."
# User.find_each do |user|
#   user.refferel_code = SecureRandom.hex(2)
#   user.save ? "Referral Code generated for #{user.email}" : "#{user.errors.full_messages.first}"
# end
