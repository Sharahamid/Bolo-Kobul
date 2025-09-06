class AddDisplayOrderToAssistedServict < ActiveRecord::Migration[6.0]
  def change
    add_column :assisted_services, :display_order, :integer, default: 0
  end
end
