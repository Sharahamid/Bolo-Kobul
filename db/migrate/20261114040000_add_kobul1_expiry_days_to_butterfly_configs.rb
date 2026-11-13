# How many days an unanswered 1st Kobul stays open (Admin > Settings > Butterfly prices)
class AddKobul1ExpiryDaysToButterflyConfigs < ActiveRecord::Migration[8.1]
  def change
    add_column :butterfly_configs, :kobul1_expiry_days, :integer, default: 7, null: false
  end
end
