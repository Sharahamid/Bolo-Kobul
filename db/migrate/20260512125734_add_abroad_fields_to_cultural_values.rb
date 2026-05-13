class AddAbroadFieldsToCulturalValues < ActiveRecord::Migration[6.0]
  def change
    add_column :cultural_values, :birth_place_country, :string
    add_column :cultural_values, :birth_place_city, :string
  end
end
