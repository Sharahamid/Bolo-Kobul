class AddLocationToMarketPlaces < ActiveRecord::Migration[6.0]
  def change
    add_column :market_places, :location, :string
  end
end
