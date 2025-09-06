class AddDegreeToAcademicInformations < ActiveRecord::Migration[6.0]
  def change
    add_column :academic_informations, :degree, :string
  end
end
