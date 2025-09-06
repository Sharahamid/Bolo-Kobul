class PassingYearChangeColumnType < ActiveRecord::Migration[6.0]
  def change
    remove_column :academic_informations, :passing_year, :integer
  end
end
