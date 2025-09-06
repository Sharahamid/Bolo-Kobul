class RemoveBooleanDataTypeFromAppearances < ActiveRecord::Migration[6.0]
  def change

    remove_column :appearances, :body_art, :boolean

    remove_column :appearances, :is_hijab, :boolean

    remove_column :appearances, :is_niqab, :boolean
  end
end
