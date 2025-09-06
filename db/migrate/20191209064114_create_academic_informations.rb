class CreateAcademicInformations < ActiveRecord::Migration[6.0]
  def change
    create_table :academic_informations do |t|
      t.integer :marriage_profile_id
      t.integer :degree
      t.integer :passing_year
      t.integer :institution
      t.integer :result
      t.datetime :start_date
      t.string :end_date
      t.string :datetime

      t.timestamps
    end
  end
end
