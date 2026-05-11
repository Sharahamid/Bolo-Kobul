class AddAuthyIdToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :authy_id, :integer
  end
end
