class RemoveHeightFtAndHeightInchFromPartnerPreferences < ActiveRecord::Migration[6.0]
  def change
    remove_column :partner_preferences, :height_ft, :integer
    remove_column :partner_preferences, :height_inch, :integer
  end
end
