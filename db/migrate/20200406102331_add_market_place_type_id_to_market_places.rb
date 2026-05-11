class AddMarketPlaceTypeIdToMarketPlaces < ActiveRecord::Migration[6.0]
  def change
    add_column :market_places, :market_place_type_id, :integer
  end
end
