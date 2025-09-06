class AddIntegerDataTypeToCulturalValues < ActiveRecord::Migration[6.0]
  def change
    add_column :cultural_values, :attend_religious_event, :integer
    add_column :cultural_values, :willing_to_relocate, :integer
  end
end
