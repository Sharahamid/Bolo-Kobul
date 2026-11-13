# A member's own biodata (PDF, Word or photo) uploaded on the Basics step: the file is kept
# privately like the ID document (admin-only), and the details read from it are kept so the
# later profile steps can offer them.
class AddBiodataToMarriageProfiles < ActiveRecord::Migration[8.1]
  def change
    add_column :marriage_profiles, :biodata_document, :string
    add_column :marriage_profiles, :biodata_data, :jsonb, default: {}, null: false
  end
end
