class AddPhysicalStatusAgainToAppearances < ActiveRecord::Migration[6.0]
  def change
    add_column :appearances, :physical_status, :integer
  end
end
