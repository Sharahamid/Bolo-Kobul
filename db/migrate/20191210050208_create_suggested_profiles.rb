class CreateSuggestedProfiles < ActiveRecord::Migration[6.0]
  def change
    create_table :suggested_profiles do |t|
      t.integer :marriage_profile_id
      t.integer :matching_percent

      t.timestamps
    end
  end
end
