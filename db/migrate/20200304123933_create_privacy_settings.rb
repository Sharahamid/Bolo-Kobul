class CreatePrivacySettings < ActiveRecord::Migration[6.0]
  def change
    create_table :privacy_settings do |t|
      t.integer :marriage_profile_id
      t.integer :gender
      t.integer :date_of_birth
      t.integer :highest_education_level

      t.timestamps
    end
  end
end
