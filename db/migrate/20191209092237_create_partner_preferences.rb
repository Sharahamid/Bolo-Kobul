class CreatePartnerPreferences < ActiveRecord::Migration[6.0]
  def change
    create_table :partner_preferences do |t|
      t.integer :marriage_profile_id
      t.integer :gender
      t.integer :max_age
      t.integer :min_age
      t.integer :max_height
      t.integer :min_height
      t.integer :hometown
      t.integer :present_location
      t.integer :marital_status
      t.integer :highest_education_level
      t.integer :family_values
      t.integer :family_type
      t.integer :family_status
      t.integer :blood_group

      t.timestamps
    end
  end
end
