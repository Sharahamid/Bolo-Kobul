class AddStatusToCustomerSupport < ActiveRecord::Migration[6.0]
  def change
    add_column :customer_supports, :status, :integer, default: 0
  end
end
