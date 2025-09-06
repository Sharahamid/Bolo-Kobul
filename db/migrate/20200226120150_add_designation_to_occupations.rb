class AddDesignationToOccupations < ActiveRecord::Migration[6.0]
  def change
    add_column :occupations, :designation, :string
  end
end
