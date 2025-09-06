class CreateTransactions < ActiveRecord::Migration[6.0]
  def change
    create_table :transactions do |t|
      t.integer :order_id
      t.integer :status
      t.decimal :amount
      t.decimal :currency_amount
      t.decimal :discount_amount
      t.decimal :discount_percentage
      t.string :card_type
      t.string :card_no
      t.string :currency
      t.string :bank_tran_id
      t.string :card_issuer
      t.string :transaction_by

      t.timestamps
    end
  end
end
