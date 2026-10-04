# Creates made-up members for the browser tests. LOCAL / TEST DATABASES ONLY.
# Usage: bin/rails runner e2e/support/seed.rb
abort('Refusing to seed test members into production') if Rails.env.production?

PASSWORD = 'Test1234pass'.freeze
FIXTURES = Rails.root.join('e2e', 'fixtures')

# Start clean: remove previous test members (all use @example.com addresses)
User.where("email LIKE '%@example.com'").find_each(&:destroy)

def member(key, name:, gender:, phone:, nid:)
  user = User.new(
    name: name, email: "#{key}@example.com", phone_number: phone, created_for: :self,
    password: PASSWORD, password_confirmation: PASSWORD
  )
  user.verified = true
  user.save!
  user.update_columns(butterfly_number: 50)

  profile = user.marriage_profiles.new(
    name: name, gender: gender, date_of_birth: Date.new(1995, 5, 20), religion: :islam,
    marital_status: :unmarried, height_ft: '5', height_inch: '6', highest_education_level: :graduate,
    blood_group: 'B+', hometown: 'Dhaka', present_location: 'Dhaka', nid_or_passport: nid,
    about_my_self: "Test profile for automated checks (#{key})."
  )
  profile.identification_document = File.open(FIXTURES.join('test-id-card.png'))
  profile.save!

  profile.create_partner_preference!(religion: :islam, gender: gender.to_s == 'male' ? :female : :male)
  [user, profile]
end

alice, alice_profile = member('alice', name: 'Alice Test', gender: :female, phone: '+8801711000001', nid: 'TESTNID0001')
bob,   bob_profile   = member('bob',   name: 'Bob Test',   gender: :male,   phone: '+8801711000002', nid: 'TESTNID0002')
carol, carol_profile = member('carol', name: 'Carol Test', gender: :female, phone: '+8801711000003', nid: 'TESTNID0003')

# Records on Bob's profile, used to check other members can't change them
bob_family = bob_profile.family_members.create!(
  name: 'Bob Test Senior', relation: FamilyMember.relations.keys.first,
  occupation: :business, residence_type: :owned
)
bob_education = bob_profile.academic_informations.create!(degree: 'BSc', institution: 'Test University')

# Alice and Bob are already connected so they can chat
alice_profile.friend_request(bob_profile)
bob_profile.accept_request(alice_profile)

admin = AdminUser.find_or_initialize_by(email: 'admin@example.com')
admin.password = admin.password_confirmation = PASSWORD
admin.role = 'super_admin' if admin.respond_to?(:role=)
admin.save!

puts({
  members: { alice: alice_profile.slug, bob: bob_profile.slug, carol: carol_profile.slug },
  bob_family_member_id: bob_family.id, bob_academic_information_id: bob_education.id,
  alice_user_slug: alice.slug,
  password: PASSWORD, admin: admin.email
}.to_json)
