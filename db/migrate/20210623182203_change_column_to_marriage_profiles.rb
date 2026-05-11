class ChangeColumnToMarriageProfiles < ActiveRecord::Migration[6.0]
  def change
    remove_column :marriage_profiles, :passport_no, :string
    rename_column :marriage_profiles, :national_id, :nid_or_passport
  end
end
