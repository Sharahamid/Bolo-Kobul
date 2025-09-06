class AddSpecificHabitsToLifeStyles < ActiveRecord::Migration[6.0]
  def change
    add_column :life_styles, :specific_habits, :text
  end
end
