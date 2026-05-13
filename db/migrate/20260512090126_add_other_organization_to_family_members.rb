class AddOtherOrganizationToFamilyMembers < ActiveRecord::Migration[6.0]
  def change
    add_column :family_members, :other_organization, :string
  end
end
