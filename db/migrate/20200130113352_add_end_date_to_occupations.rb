class AddEndDateToOccupations < ActiveRecord::Migration[6.0]
  def change
    add_column :occupations, :end_date, :datetime
  end
end
