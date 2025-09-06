class CreateConfigurations < ActiveRecord::Migration[6.0]
  def change
    create_table :configurations do |t|
      t.string :butterfly_price
      t.timestamps
    end
  end
end
