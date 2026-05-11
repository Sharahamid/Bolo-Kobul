class RemovePhysicalStatusFromMarrigeProfiles < ActiveRecord::Migration[6.0]
  def change
    remove_column :marriage_profiles, :physical_status, :integer
  end
end
