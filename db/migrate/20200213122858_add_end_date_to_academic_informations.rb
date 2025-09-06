class AddEndDateToAcademicInformations < ActiveRecord::Migration[6.0]
  def change
    add_column :academic_informations, :end_date, :datetime
  end
end
