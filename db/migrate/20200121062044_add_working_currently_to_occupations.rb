class AddWorkingCurrentlyToOccupations < ActiveRecord::Migration[6.0]
  def change
    add_column :occupations, :working_currently, :boolean
  end
end
