class LinkToMarketPlaces < ActiveRecord::Migration[6.0]
  def change
    add_column :market_places, :link, :string
  end
end
