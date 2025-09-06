class AddSlugToMarriageProfiles < ActiveRecord::Migration[6.0]
  def change
    add_column :marriage_profiles, :slug, :string
    add_index :marriage_profiles, :slug, unique: true
  end
end
