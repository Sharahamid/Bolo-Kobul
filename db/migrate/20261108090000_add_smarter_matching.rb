# Smarter matching (November 2026): must-haves, wanted professions and relocation in
# partner preferences, plus a record of profiles a member has passed on, so they stop
# appearing in that member's recommendations.
class AddSmarterMatching < ActiveRecord::Migration[8.1]
  def change
    add_column :partner_preferences, :must_haves, :text
    add_column :partner_preferences, :occupations, :text
    add_column :partner_preferences, :relocation_needed, :boolean, default: false, null: false

    create_table :profile_passes do |t|
      t.integer :marriage_profile_id, null: false
      t.integer :passed_profile_id, null: false
      t.timestamps
    end
    add_index :profile_passes, %i[marriage_profile_id passed_profile_id], unique: true
  end
end
