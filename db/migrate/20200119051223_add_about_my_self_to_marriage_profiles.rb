class AddAboutMySelfToMarriageProfiles < ActiveRecord::Migration[6.0]
  def change
    add_column :marriage_profiles, :about_my_self, :text
  end
end
