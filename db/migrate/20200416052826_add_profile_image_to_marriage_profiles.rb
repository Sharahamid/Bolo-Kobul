class AddProfileImageToMarriageProfiles < ActiveRecord::Migration[6.0]
  def change
    add_column :marriage_profiles, :profile_image, :string
  end
end
