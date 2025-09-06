class AddCompanyNameToOccupation < ActiveRecord::Migration[6.0]
  def change
    add_column :occupations, :company_name, :string
  end
end
