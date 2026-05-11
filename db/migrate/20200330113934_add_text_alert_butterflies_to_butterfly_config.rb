class AddTextAlertButterfliesToButterflyConfig < ActiveRecord::Migration[6.0]
  def change
    add_column :butterfly_configs, :text_alert_butterflies, :integer, default: 0
  end
end
