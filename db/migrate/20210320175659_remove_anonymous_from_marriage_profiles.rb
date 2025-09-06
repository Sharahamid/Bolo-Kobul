class RemoveAnonymousFromMarriageProfiles < ActiveRecord::Migration[6.0]
  def change
    remove_column :marriage_profiles, :anonymous, :string
  end
end
