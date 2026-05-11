class CreateAppearances < ActiveRecord::Migration[6.0]
  def change
    create_table :appearances do |t|
      t.integer :marriage_profile_id
      t.integer :hair_color
      t.integer :hair_length
      t.integer :hair_type
      t.boolean :eye_wear
      t.decimal :weight
      t.integer :body_type
      t.boolean :body_art
      t.boolean :is_niqab
      t.boolean :is_hijab
      t.integer :complexion

      t.timestamps
    end
  end
end
