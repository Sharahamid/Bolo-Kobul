# A member's saved search filters, so they can run the same search again in one tap
# and see how many new profiles match since last time.
class CreateSavedSearches < ActiveRecord::Migration[8.1]
  def change
    create_table :saved_searches do |t|
      t.references :marriage_profile, null: false, index: true
      t.string :name, null: false
      t.jsonb :criteria, null: false, default: {}
      t.datetime :last_run_at
      t.timestamps
    end
  end
end
