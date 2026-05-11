class AddSpecialCircumstancesAndDescriptionToMarriageProfiles < ActiveRecord::Migration[6.0]
  def change
    add_column :marriage_profiles, :description, :text
    add_column :marriage_profiles, :special_circumstances, :text
  end
end
