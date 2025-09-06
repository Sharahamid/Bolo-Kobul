class AddDefaultValuesInGenderDateOfBirthAndHighestEducationLevelToPrivacySettings < ActiveRecord::Migration[6.0]
  def change
    change_column :privacy_settings, :gender, :integer, default: 0
    change_column :privacy_settings, :date_of_birth, :integer, default: 1
    change_column :privacy_settings, :highest_education_level, :integer, default: 1
  end
end
