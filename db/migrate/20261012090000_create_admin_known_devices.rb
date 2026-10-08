class CreateAdminKnownDevices < ActiveRecord::Migration[8.1]
  def change
    create_table :admin_known_devices do |t|
      t.references :admin_user, null: false, foreign_key: true
      t.string :token_digest, null: false
      t.string :user_agent
      t.string :ip
      t.datetime :last_seen_at
      t.timestamps
    end
    add_index :admin_known_devices, :token_digest, unique: true
  end
end
