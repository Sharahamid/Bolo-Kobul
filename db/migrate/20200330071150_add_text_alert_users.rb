class AddTextAlertUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :text_alert, :integer, default: 0
  end
end
