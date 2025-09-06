class AddEyeColorToAppearances < ActiveRecord::Migration[6.0]
  def change
    add_column :appearances, :eye_color, :string
  end
end
