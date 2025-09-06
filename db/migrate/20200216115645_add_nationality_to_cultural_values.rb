class AddNationalityToCulturalValues < ActiveRecord::Migration[6.0]
  def change
    add_column :cultural_values, :nationality, :string
  end
end
