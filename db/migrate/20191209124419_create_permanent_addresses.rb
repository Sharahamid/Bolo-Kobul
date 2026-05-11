class CreatePermanentAddresses < ActiveRecord::Migration[6.0]
  def change
    create_table :permanent_addresses do |t|
      t.string :addressable_type
      t.integer :addressable_id
      t.integer :division
      t.integer :district
      t.integer :thana
      t.integer :union
      t.string :address_details

      t.timestamps
    end
  end
end
