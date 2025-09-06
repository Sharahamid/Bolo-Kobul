class AddAnnualIncomeAndOccupationToOccupations < ActiveRecord::Migration[6.0]
  def change
    add_column :occupations, :annual_income, :integer
    add_column :occupations, :name, :integer
  end
end
