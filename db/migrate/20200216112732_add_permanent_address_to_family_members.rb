class AddPermanentAddressToFamilyMembers < ActiveRecord::Migration[6.0]
  def change
    add_column :family_members, :permanent_address, :string
  end
end
