class RemoveDegreeFromAcademicInformations < ActiveRecord::Migration[6.0]
  def change

    remove_column :academic_informations, :degree, :integer
  end
end
