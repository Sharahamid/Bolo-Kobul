class RemoveEyeWearFromAppearances < ActiveRecord::Migration[6.0]
  def change

    remove_column :appearances, :eye_wear, :boolean
  end
end
