class AddFavouriteBookAndFavouriteSongToHobbiesAndInterests < ActiveRecord::Migration[6.0]
  def change
    add_column :hobbies_and_interests, :favourite_book, :string
    add_column :hobbies_and_interests, :favourite_song, :string
  end
end
