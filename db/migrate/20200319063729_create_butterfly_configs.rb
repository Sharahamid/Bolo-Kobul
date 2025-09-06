class CreateButterflyConfigs < ActiveRecord::Migration[6.0]
  def change
    create_table :butterfly_configs do |t|
      t.integer :profile_view_butterflies, default: 0
      t.integer :chat_butterflies, default: 0
      t.float :butterfly_price, default: 0.0

      t.timestamps
    end
  end
end
