class CreateAdvertiserProfiles < ActiveRecord::Migration[6.0]
  def change
    create_table :advertiser_profiles do |t|
      t.integer :user_id
      t.string :name
      t.string :email
      t.string :license_number
      t.integer :total_earning

      t.timestamps
    end
  end
end
