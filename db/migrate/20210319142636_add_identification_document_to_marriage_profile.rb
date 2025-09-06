class AddIdentificationDocumentToMarriageProfile < ActiveRecord::Migration[6.0]
  def change
    add_column :marriage_profiles, :identification_document, :string
  end
end
