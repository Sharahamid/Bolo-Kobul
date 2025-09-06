class ChangeBloodGroupToPartnerPreference < ActiveRecord::Migration[6.0]
  def up
    change_column :partner_preferences, :blood_group, :text
  end

  def down
    change_column :partner_preferences, :blood_group, :integer
  end
end
