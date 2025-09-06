class RemovePhoneFromContacts < ActiveRecord::Migration[6.0]
  def change

    remove_column :contacts, :phone, :string
  end
end
