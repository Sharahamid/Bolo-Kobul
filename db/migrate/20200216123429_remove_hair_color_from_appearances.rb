class RemoveHairColorFromAppearances < ActiveRecord::Migration[6.0]
  def change

    remove_column :appearances, :hair_color, :integer
    remove_column :appearances, :hair_type, :integer
  end
end
