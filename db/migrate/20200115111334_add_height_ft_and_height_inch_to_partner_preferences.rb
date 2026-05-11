class AddHeightFtAndHeightInchToPartnerPreferences < ActiveRecord::Migration[6.0]
  def change
    add_column :partner_preferences, :height_ft, :integer
    add_column :partner_preferences, :height_inch, :integer
  end
end
