class AddDateOfBirthFromMarriageProfiles < ActiveRecord::Migration[6.0]
  def change
    add_column :marriage_profiles, :date_of_birth, :datetime
  end
end
