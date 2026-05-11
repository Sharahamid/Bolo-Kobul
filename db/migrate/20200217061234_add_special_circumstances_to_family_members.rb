class AddSpecialCircumstancesToFamilyMembers < ActiveRecord::Migration[6.0]
  def change
    add_column :family_members, :special_circumstances, :text
  end
end
