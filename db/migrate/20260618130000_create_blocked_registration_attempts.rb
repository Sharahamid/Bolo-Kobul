class CreateBlockedRegistrationAttempts < ActiveRecord::Migration[6.0]
  def change
    create_table :blocked_registration_attempts do |t|
      t.string :name
      t.string :email
      t.string :phone
      t.string :attempt_type
      t.string :ip_address

      t.timestamps
    end
  end
end
