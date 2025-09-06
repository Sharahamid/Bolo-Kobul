class RemoveMaxAndMinHeightToPartnerPreferences < ActiveRecord::Migration[6.0]
  def change
    remove_column :partner_preferences, :max_height
    remove_column :partner_preferences, :min_height
  end
end
