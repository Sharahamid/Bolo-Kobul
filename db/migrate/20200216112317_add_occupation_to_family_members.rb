class AddOccupationToFamilyMembers < ActiveRecord::Migration[6.0]
  def change
    add_column :family_members, :occupation, :integer
  end
end
