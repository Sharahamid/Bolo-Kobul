class AddIsReferenceToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :is_reference, :boolean, default: false
  end
end
