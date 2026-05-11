class RemoveNationalityFromCulturalValues < ActiveRecord::Migration[6.0]
  def change

    remove_column :cultural_values, :nationality, :integer
  end
end
