class CreateOccupations < ActiveRecord::Migration[6.0]
  def change
    create_table :occupations do |t|
      t.integer :marriage_profile_id
      t.integer :title
      t.integer :organization
      t.integer :employment_status
      t.integer :designation
      t.decimal :annual_income
      t.datetime :start_date
      t.string :end_date
      t.string :datetime
      t.string :working_currently
      t.string :boolean

      t.timestamps
    end
  end
end
