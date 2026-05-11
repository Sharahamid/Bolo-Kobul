class AddMusicAndReadToHobbiesAndInterests < ActiveRecord::Migration[6.0]
  def change
    add_column :hobbies_and_interests, :music, :text
    add_column :hobbies_and_interests, :read, :text
  end
end
