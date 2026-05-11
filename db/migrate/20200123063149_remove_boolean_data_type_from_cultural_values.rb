class RemoveBooleanDataTypeFromCulturalValues < ActiveRecord::Migration[6.0]
  def change

    remove_column :cultural_values, :attend_religious_event, :boolean

    remove_column :cultural_values, :willing_to_relocate, :boolean
  end
end
