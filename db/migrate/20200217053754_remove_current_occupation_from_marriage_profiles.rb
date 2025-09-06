class RemoveCurrentOccupationFromMarriageProfiles < ActiveRecord::Migration[6.0]
  def change

    remove_column :marriage_profiles, :current_occupation, :integer
  end
end
