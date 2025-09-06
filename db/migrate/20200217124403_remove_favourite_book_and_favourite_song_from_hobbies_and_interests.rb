class RemoveFavouriteBookAndFavouriteSongFromHobbiesAndInterests < ActiveRecord::Migration[6.0]
  def change

    remove_column :hobbies_and_interests, :favourite_book, :text

    remove_column :hobbies_and_interests, :favourite_song, :text
  end
end
