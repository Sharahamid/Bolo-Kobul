class AddHairColorToAppearances < ActiveRecord::Migration[6.0]
  def change
    add_column :appearances, :hair_color, :string
    add_column :appearances, :hair_type, :string
  end
end
