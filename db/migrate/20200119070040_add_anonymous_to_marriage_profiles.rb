class AddAnonymousToMarriageProfiles < ActiveRecord::Migration[6.0]
  def change
    add_column :marriage_profiles, :anonymous, :string
  end
end
