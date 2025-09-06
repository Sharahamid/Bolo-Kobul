class AddPassportNoToMarriageProfiles < ActiveRecord::Migration[6.0]
  def change
    add_column :marriage_profiles, :passport_no, :string
  end
end
