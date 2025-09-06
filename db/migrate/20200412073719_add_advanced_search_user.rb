class AddAdvancedSearchUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :advanced_search, :integer, default: 0
  end
end
