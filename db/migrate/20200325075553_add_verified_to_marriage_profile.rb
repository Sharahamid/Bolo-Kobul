class AddVerifiedToMarriageProfile < ActiveRecord::Migration[6.0]
  def change
    add_column :marriage_profiles, :verified, :boolean
  end
end
