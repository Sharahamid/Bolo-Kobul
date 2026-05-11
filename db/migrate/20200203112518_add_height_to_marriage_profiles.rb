class AddHeightToMarriageProfiles < ActiveRecord::Migration[6.0]
  def change
    add_column :marriage_profiles, :height_ft, :integer
  end
end
