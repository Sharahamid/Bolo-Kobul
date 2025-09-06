class AddPhotosToMarriageProfiles < ActiveRecord::Migration[6.0]
  def change
    add_column :marriage_profiles, :photo_1, :string
    add_column :marriage_profiles, :photo_2, :string
    add_column :marriage_profiles, :photo_3, :string
  end
end
