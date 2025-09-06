class RemoveHairLengthFromAppearances < ActiveRecord::Migration[6.0]
  def change

    remove_column :appearances, :hair_length, :integer
  end
end
