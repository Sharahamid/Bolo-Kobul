class AddMonthlyIncomeToOccupations < ActiveRecord::Migration[6.0]
  def change
    add_column :occupations, :monthly_income, :integer
  end
end
