class CreateMarketPlaces < ActiveRecord::Migration[6.0]
  def change
    create_table :market_places do |t|
      t.string :name
      t.decimal :cost
      t.integer :status, default: 0
      t.integer :market_type, default: 0
      t.string :costing_unit
      t.text :facility
      t.text :policy
      t.text :experience
      t.text :about

      t.timestamps
    end
  end
end
