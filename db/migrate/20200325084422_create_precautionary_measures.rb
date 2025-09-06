class CreatePrecautionaryMeasures < ActiveRecord::Migration[6.0]
  def change
    create_table :precautionary_measures do |t|
      t.string :title
      t.text :content
      t.integer :display_order, default: 0

      t.timestamps
    end
  end
end
