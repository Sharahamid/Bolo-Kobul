class AddColumnFreeButterflyToConfiguration < ActiveRecord::Migration[6.0]
  def change
    add_column :butterfly_configs, :num_of_free_butterfly, :integer, default: 0
  end
end
