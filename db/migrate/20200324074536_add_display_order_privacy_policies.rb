class AddDisplayOrderPrivacyPolicies < ActiveRecord::Migration[6.0]
  def change
    add_column :privacy_policies, :display_order, :integer, default: 0
  end
end
