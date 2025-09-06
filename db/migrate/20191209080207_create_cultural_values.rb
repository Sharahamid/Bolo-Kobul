class CreateCulturalValues < ActiveRecord::Migration[6.0]
  def change
    create_table :cultural_values do |t|
      t.integer :marriage_profile_id
      t.integer :nationality
      t.integer :birth_place
      t.boolean :willing_to_relocate
      t.integer :mother_tongue
      t.text :languages_spoken
      t.integer :religion
      t.integer :resident_type
      t.boolean :attend_religious_event
      t.text :political_view

      t.timestamps
    end
  end
end
