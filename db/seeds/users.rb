require 'csv'

puts '--------------------- running seed users.rb'
csv_text = File.read(File.join(Rails.root, '/db/seeds/data/users.csv'))
csv = CSV.parse(csv_text, headers: true)

csv.each do |row|
  user = User.find_by(email: row['email'])
  next if user.present?

  new_user = User.create(
    email: row['email'],
    name: row['name'],
    national_id: row['national_id'] || '',
    phone_number: row['phone_number'],
    created_for: :self,
    password: '@Bolokobul123@',
    confirmed_at: Time.now.utc
  )

  if new_user.valid?
    new_user.update_column(:encrypted_password, row['encrypted_password'])
  end

  puts "----new user created #{new_user.valid?}, #{new_user.errors.full_messages}"
end
