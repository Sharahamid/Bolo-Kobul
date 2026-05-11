class AddCategoryToNotification < ActiveRecord::Migration[6.0]
  def change
    add_column :notifications, :category, :integer, default: 0
  end
end
