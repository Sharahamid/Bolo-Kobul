class AddMaxInchAndMinInchToPartnerPreferences < ActiveRecord::Migration[6.0]
  def change
    add_column :partner_preferences, :max_inch, :integer
    add_column :partner_preferences, :min_inch, :integer
  end
end
