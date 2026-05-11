class AddMusicTypeAndReadingTypeToHobbiesAndInterests < ActiveRecord::Migration[6.0]
  def change
    add_column :hobbies_and_interests, :music_type, :text
    add_column :hobbies_and_interests, :reading_type, :text
    add_column :hobbies_and_interests, :specific_entertainment, :string
  end
end
