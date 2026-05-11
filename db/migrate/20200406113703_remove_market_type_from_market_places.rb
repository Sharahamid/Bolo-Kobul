class RemoveMarketTypeFromMarketPlaces < ActiveRecord::Migration[6.0]
  def change

    remove_column :market_places, :market_type, :integer
  end
end
