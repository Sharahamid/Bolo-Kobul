class CreateLifeStyles < ActiveRecord::Migration[6.0]
  def change
    create_table :life_styles do |t|
      t.integer :marriage_profile_id
      t.boolean :drinker
      t.boolean :smoker
      t.integer :food_habits
      t.integer :dress_style
      t.integer :living_with

      t.timestamps
    end
  end
end
