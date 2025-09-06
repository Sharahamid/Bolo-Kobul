class AddHeadingToContacts < ActiveRecord::Migration[6.0]
  def change
    add_column :contacts, :heading, :string
  end
end
