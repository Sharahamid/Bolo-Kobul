class RemoveOccupationFromFamilyMembers < ActiveRecord::Migration[6.0]
  def change

    remove_column :family_members, :occupation, :string
  end
end
