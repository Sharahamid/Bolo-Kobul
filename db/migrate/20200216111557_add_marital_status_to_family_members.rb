class AddMaritalStatusToFamilyMembers < ActiveRecord::Migration[6.0]
  def change
    add_column :family_members, :marital_status, :integer
  end
end
