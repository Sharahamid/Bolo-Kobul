class AddDocVerificationStatusToMarriageProfiles < ActiveRecord::Migration[6.0]
  def change
    add_column :marriage_profiles, :doc_verification_status, :integer
  end
end
