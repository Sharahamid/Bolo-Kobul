class AddColumnCurrentButterflyBlockButterflyUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :butterfly_number, :integer
    add_column :users, :block_butterfly_number, :integer
  end
end
