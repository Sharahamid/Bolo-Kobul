class AddServiceCoverageToMarketPlaces < ActiveRecord::Migration[6.0]
  def change
    add_column :market_places, :service_coverage, :string
  end
end
