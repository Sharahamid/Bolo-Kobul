class AddOtherFieldsToMarriageProfiles < ActiveRecord::Migration[6.0]
  def change
    add_column :marriage_profiles, :other_religion, :string
    add_column :marriage_profiles, :other_education, :string
    add_column :marriage_profiles, :other_gender, :string
  end
end
