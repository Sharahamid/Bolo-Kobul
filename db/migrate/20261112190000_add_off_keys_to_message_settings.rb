# Lets each SMS and email be switched off on its own (Admin > Manage Site > Messages On / Off)
class AddOffKeysToMessageSettings < ActiveRecord::Migration[8.1]
  def change
    add_column :message_settings, :off_keys, :jsonb, null: false, default: []
  end
end
