class AddReligionToPartnerPreferences < ActiveRecord::Migration[6.0]
  def change
    add_column :partner_preferences, :religion, :integer
  end
end
