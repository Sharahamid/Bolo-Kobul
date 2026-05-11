class AddNewColumnToAdsTable < ActiveRecord::Migration[6.0]
  def change
    reversible do |dir|
      dir.up do
        add_column :ads, :status, :integer, default: 0
        add_column :ads, :price, :integer, default: 0
        rename_column :ads, :ad_location_id, :location
        change_column_default :ads, :location, from: nil, to: 0
      end

      dir.down do
        change_column_default :ads, :location, from: 0, to: nil
        rename_column :ads, :location, :ad_location_id
        remove_column :ads, :price
        remove_column :ads, :status
      end
    end
  end
end
