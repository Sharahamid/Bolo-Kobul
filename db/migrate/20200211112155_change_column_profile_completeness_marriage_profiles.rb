class ChangeColumnProfileCompletenessMarriageProfiles < ActiveRecord::Migration[6.0]
  def change
    change_column :marriage_profiles, :profile_completeness, :integer, default: 0
  end
end
