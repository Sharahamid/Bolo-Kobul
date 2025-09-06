class AddColumnsToOrders < ActiveRecord::Migration[6.0]
  def change
    add_column :orders, :product, :integer, default: 0
    add_column :orders, :customer_name, :string
    add_column :orders, :customer_phone, :string
    add_column :orders, :customer_email, :string
    add_reference :orders, :assisted_service, index: true
  end
end
