# "Not interested": a member hides a profile from their own recommendations and searches.
class CreateProfileHides < ActiveRecord::Migration[8.1]
  def change
    create_table :profile_hides do |t|
      t.bigint :marriage_profile_id, null: false
      t.bigint :hidden_profile_id, null: false
      t.timestamps
    end
    add_index :profile_hides, [:marriage_profile_id, :hidden_profile_id], unique: true
    add_index :profile_hides, :hidden_profile_id
  end
end
