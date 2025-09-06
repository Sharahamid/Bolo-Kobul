class AddRefferelCodeToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :refferel_code, :string
  end
end
