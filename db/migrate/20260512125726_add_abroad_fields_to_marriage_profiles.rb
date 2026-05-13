class AddAbroadFieldsToMarriageProfiles < ActiveRecord::Migration[6.0]
  def change
    add_column :marriage_profiles, :hometown_country, :string
    add_column :marriage_profiles, :hometown_city, :string
    add_column :marriage_profiles, :present_location_country, :string
    add_column :marriage_profiles, :present_location_city, :string
  end
end
