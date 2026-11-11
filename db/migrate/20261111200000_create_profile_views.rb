# Who viewed whose profile (one row per viewer and profile; the time and count update
# on each visit). Powers "Who viewed you" for BK+ members.
class CreateProfileViews < ActiveRecord::Migration[8.1]
  def change
    create_table :profile_views do |t|
      t.integer :viewer_id, null: false   # marriage_profiles.id of the member who looked
      t.integer :viewed_id, null: false   # marriage_profiles.id of the profile looked at
      t.integer :views_count, default: 1, null: false
      t.datetime :last_viewed_at, null: false
      t.timestamps
    end
    add_index :profile_views, %i[viewed_id viewer_id], unique: true
    add_index :profile_views, %i[viewed_id last_viewed_at]
  end
end
