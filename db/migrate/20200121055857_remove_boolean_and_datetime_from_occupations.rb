class RemoveBooleanAndDatetimeFromOccupations < ActiveRecord::Migration[6.0]
  def change
    remove_column :occupations, :boolean, :string
    remove_column :occupations, :datetime, :string
  end
end
