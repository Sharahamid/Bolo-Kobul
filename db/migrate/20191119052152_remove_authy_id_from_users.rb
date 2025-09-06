class RemoveAuthyIdFromUsers < ActiveRecord::Migration[6.0]
  def change

    remove_column :users, :authy_id, :integer
  end
end
