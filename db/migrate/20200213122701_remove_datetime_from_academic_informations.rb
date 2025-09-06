class RemoveDatetimeFromAcademicInformations < ActiveRecord::Migration[6.0]
  def change
    remove_column :academic_informations, :datetime, :string
    remove_column :academic_informations, :end_date, :string
  end
end
