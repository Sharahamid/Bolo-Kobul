class RemoveInstitutionFromAcademicInformations < ActiveRecord::Migration[6.0]
  def change

    remove_column :academic_informations, :institution, :integer
  end
end
