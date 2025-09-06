class RemoveHometownAndPresentLocationFromMarriageProfiles < ActiveRecord::Migration[6.0]
  def up
    if column_exists?(:marriage_profiles, :hometown)
      remove_column :marriage_profiles, :hometown, :integer
    end

    if column_exists?(:marriage_profiles, :present_location)
      remove_column :marriage_profiles, :present_location, :integer
    end
  end
end
