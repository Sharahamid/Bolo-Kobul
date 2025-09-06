class CreateProcessFlows < ActiveRecord::Migration[6.0]
  def change
    create_table :process_flows do |t|
      t.string :title
      t.text :content
      t.integer :display_order, default: 0

      t.timestamps
    end
  end
end
