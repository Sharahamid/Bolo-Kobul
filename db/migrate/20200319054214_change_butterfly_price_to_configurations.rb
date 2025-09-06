class ChangeButterflyPriceToConfigurations < ActiveRecord::Migration[6.0]
  def change
    remove_column :configurations, :butterfly_price
    add_column :configurations, :butterfly_price, :float, default: 0.0
  end
end
