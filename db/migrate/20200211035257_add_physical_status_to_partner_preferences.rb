class AddPhysicalStatusToPartnerPreferences < ActiveRecord::Migration[6.0]
  def change
    add_column :partner_preferences, :physical_status, :integer
  end
end
