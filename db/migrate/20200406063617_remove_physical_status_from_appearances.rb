class RemovePhysicalStatusFromAppearances < ActiveRecord::Migration[6.0]
  def change

    remove_column :appearances, :physical_status, :string
  end
end
