class AddPhysicalStatusToAppearances < ActiveRecord::Migration[6.0]
  def change
    add_column :appearances, :physical_status, :string
  end
end
