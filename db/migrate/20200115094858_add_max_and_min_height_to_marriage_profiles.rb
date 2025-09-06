class AddMaxAndMinHeightToMarriageProfiles < ActiveRecord::Migration[6.0]
  def change
    add_column :marriage_profiles, :max_height, :integer
    add_column :marriage_profiles, :min_height, :integer
  end
end
