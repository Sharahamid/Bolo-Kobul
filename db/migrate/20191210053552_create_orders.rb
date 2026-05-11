class CreateOrders < ActiveRecord::Migration[6.0]
  def change
    create_table :orders do |t|
      t.integer :user_id
      t.integer :quantity
      t.integer :payment_method
      t.integer :status
      t.decimal :price
      t.decimal :sub_total_amount
      t.string :promo_code
      t.decimal :discount_amount
      t.decimal :total_amount

      t.timestamps
    end
  end
end
