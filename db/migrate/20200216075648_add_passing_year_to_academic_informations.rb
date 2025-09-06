class AddPassingYearToAcademicInformations < ActiveRecord::Migration[6.0]
  def change
    add_column :academic_informations, :passing_year, :string
  end
end
