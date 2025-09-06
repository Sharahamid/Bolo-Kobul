class RemoveDateOfBirthFromMarriageProfiles < ActiveRecord::Migration[6.0]
  def change

    remove_column :marriage_profiles, :date_of_birth, :integer
  end
end
