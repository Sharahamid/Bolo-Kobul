class AddFavouriteIdToFavourites < ActiveRecord::Migration[6.0]
  def change
    add_column :favourites, :favourite_profile_id, :integer
  end
end
