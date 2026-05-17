class AddExceptHometownAbroadToPartnerPreferences < ActiveRecord::Migration[6.0]
  def change
    add_column :partner_preferences, :except_hometown_country, :string
    add_column :partner_preferences, :except_hometown_city, :string
  end
end
