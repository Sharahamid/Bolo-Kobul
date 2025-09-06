class CreateHobbiesAndInterests < ActiveRecord::Migration[6.0]
  def change
    create_table :hobbies_and_interests do |t|
      t.integer :marriage_profile_id
      t.text :hobby
      t.text :interest
      t.text :favourite_song
      t.text :favourite_book
      t.text :favourite_movie
      t.text :favourite_tv_show
      t.text :favourite_sports_show
      t.text :fitness_activity
      t.text :cuisine
      t.text :travel

      t.timestamps
    end
  end
end
