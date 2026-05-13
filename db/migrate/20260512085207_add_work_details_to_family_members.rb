class AddWorkDetailsToFamilyMembers < ActiveRecord::Migration[6.0]
  def change
    add_column :family_members, :organization, :string
    add_column :family_members, :company_name, :string
    add_column :family_members, :designation, :string
  end
end
