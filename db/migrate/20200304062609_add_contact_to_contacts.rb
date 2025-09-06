class AddContactToContacts < ActiveRecord::Migration[6.0]
  def change
    add_column :contacts, :contact, :string
  end
end
