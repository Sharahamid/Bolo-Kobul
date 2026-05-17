class AddAbroadFieldsToPartnerPreferences < ActiveRecord::Migration[6.0]
  def change
    add_column :partner_preferences, :hometown_country, :string
    add_column :partner_preferences, :hometown_city, :string
    add_column :partner_preferences, :present_location_country, :string
    add_column :partner_preferences, :present_location_city, :string
  end
end
