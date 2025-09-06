class CreateAdLocations < ActiveRecord::Migration[6.0]
  def change
    create_table :ad_locations do |t|
      t.integer :location

      t.timestamps
    end
  end
end
