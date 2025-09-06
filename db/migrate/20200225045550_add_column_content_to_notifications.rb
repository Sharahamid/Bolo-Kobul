class AddColumnContentToNotifications < ActiveRecord::Migration[6.0]
  def up
    add_column :notifications, :content, :text
    change_column :notifications, :is_read, :boolean, default: false
  end

  def down
    remove_column :notifications, :content, :text
    change_column_default :notifications, :is_read, nil
  end
end
