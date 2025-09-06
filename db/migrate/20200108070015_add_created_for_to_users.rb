class AddCreatedForToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :created_for, :integer
  end
end
