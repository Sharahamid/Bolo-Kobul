class RemoveHometownAndPresentLocationFromPartnerPreferences < ActiveRecord::Migration[6.0]
  def change

    remove_column :partner_preferences, :hometown, :integer

    remove_column :partner_preferences, :present_location, :integer
  end
end
