class AddTxnNoToOrders < ActiveRecord::Migration[6.0]
  def change
    add_column :orders, :txn_no, :string
  end
end
