class AddExceptHometownToPartnerPreferences < ActiveRecord::Migration[6.0]
  def change
    add_column :partner_preferences, :except_hometown, :text
  end
end
