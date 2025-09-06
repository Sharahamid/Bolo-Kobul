class AddNationalIdToMarriageProfiles < ActiveRecord::Migration[6.0]
  def change
    add_column :marriage_profiles, :national_id, :string
  end
end
