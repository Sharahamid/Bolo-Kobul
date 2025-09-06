class RemoveAnnualIncomeAndTitleFromOccupations < ActiveRecord::Migration[6.0]
  def change

    remove_column :occupations, :annual_income, :decimal

    remove_column :occupations, :title, :integer
  end
end
