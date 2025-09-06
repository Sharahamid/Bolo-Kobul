class RemoveMaxAndMinHeightToMarriageProfiles < ActiveRecord::Migration[6.0]
  def change
    remove_column :marriage_profiles, :max_height
    remove_column :marriage_profiles, :min_height
  end
end
