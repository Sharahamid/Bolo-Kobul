class RemoveEndDateFromOccupations < ActiveRecord::Migration[6.0]
  def change

    remove_column :occupations, :end_date, :string
  end
end
