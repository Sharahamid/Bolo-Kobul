class RemoveWorkingCurrentlyFromOccupations < ActiveRecord::Migration[6.0]
  def change

    remove_column :occupations, :working_currently, :string
  end
end
