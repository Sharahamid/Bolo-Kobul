class AddHometownAndPresentLocationToPartnerPreferences < ActiveRecord::Migration[6.0]
  def change
    add_column :partner_preferences, :hometown, :text
    add_column :partner_preferences, :present_location, :text
  end
end
