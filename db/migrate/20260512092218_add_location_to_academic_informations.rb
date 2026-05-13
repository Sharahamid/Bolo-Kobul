class AddLocationToAcademicInformations < ActiveRecord::Migration[6.0]
  def change
    add_column :academic_informations, :location, :string
  end
end
