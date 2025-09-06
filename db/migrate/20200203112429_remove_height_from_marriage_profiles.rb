class RemoveHeightFromMarriageProfiles < ActiveRecord::Migration[6.0]
  def change

    remove_column :marriage_profiles, :height, :integer
  end
end
