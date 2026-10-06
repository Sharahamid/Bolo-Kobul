class CreateProfileReports < ActiveRecord::Migration[8.1]
  def change
    create_table :profile_reports do |t|
      t.references :reporter_profile, foreign_key: { to_table: :marriage_profiles, on_delete: :nullify }
      t.references :reported_profile, null: false, foreign_key: { to_table: :marriage_profiles, on_delete: :cascade }
      t.string :reason, null: false
      t.text :details
      t.string :status, null: false, default: 'open'
      t.text :admin_note
      t.timestamps
    end
    add_index :profile_reports, :status
  end
end
