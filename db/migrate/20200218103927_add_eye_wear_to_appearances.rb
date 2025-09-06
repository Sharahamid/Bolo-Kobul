class AddEyeWearToAppearances < ActiveRecord::Migration[6.0]
  def change
    add_column :appearances, :eye_wear, :integer
  end
end
