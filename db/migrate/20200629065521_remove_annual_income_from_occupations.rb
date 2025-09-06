class RemoveAnnualIncomeFromOccupations < ActiveRecord::Migration[6.0]
  def change
    remove_column :occupations, :annual_income, :integer
  end
end
