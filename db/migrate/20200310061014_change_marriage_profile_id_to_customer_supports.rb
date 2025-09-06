class ChangeMarriageProfileIdToCustomerSupports < ActiveRecord::Migration[6.0]
  def change
    rename_column :customer_supports, :marriage_profile_id, :user_id
  end
end
