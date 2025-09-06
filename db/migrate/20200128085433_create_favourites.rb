class CreateFavourites < ActiveRecord::Migration[6.0]
  def change
    create_table :favourites do |t|
      t.integer :marriage_profile_id

      t.timestamps
    end
  end
end
