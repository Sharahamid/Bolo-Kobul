class AddOtherOrganizationToOccupations < ActiveRecord::Migration[6.0]
  def change
    add_column :occupations, :other_organization, :string
  end
end
