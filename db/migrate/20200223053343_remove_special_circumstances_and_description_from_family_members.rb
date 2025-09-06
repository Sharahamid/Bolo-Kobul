class RemoveSpecialCircumstancesAndDescriptionFromFamilyMembers < ActiveRecord::Migration[6.0]
  def change

    remove_column :family_members, :description, :string

    remove_column :family_members, :special_circumstances, :text
  end
end
