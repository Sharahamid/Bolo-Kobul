class AddHometownAndPresentLocationToMarriageProfiles < ActiveRecord::Migration[6.0]
  def up
    add_column :marriage_profiles, :hometown, :text
    add_column :marriage_profiles, :present_location, :text
  end

  def down
    if column_exists?(:marriage_profiles, :hometown)
      remove_column :marriage_profiles, :hometown, :text
    end

    if column_exists?(:marriage_profiles, :present_location)
      remove_column :marriage_profiles, :present_location, :text
    end
  end
end
