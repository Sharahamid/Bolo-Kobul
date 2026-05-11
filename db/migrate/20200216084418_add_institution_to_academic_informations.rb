class AddInstitutionToAcademicInformations < ActiveRecord::Migration[6.0]
  def change
    add_column :academic_informations, :institution, :string
  end
end
