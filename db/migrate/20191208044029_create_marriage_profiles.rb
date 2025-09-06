class CreateMarriageProfiles < ActiveRecord::Migration[6.0]
  def change
    create_table :marriage_profiles do |t|
      t.integer :user_id
      t.string :email
      t.string :name
      t.integer :gender
      t.integer :date_of_birth
      t.integer :marital_status
      t.integer :height
      t.integer :highest_education_level
      t.integer :current_occupation
      t.integer :physical_status
      t.integer :family_values
      t.integer :family_type
      t.integer :family_status
      t.integer :blood_group
      t.integer :relation
      t.integer :profile_completeness

      t.timestamps
    end
  end
end
