class AddHairLengthToAppearances < ActiveRecord::Migration[6.0]
  def change
    add_column :appearances, :hair_length, :string
  end
end
