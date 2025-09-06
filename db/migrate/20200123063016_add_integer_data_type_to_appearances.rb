class AddIntegerDataTypeToAppearances < ActiveRecord::Migration[6.0]
  def change
    add_column :appearances, :body_art, :integer
    add_column :appearances, :is_hijab, :integer
    add_column :appearances, :is_niqab, :integer
  end
end
