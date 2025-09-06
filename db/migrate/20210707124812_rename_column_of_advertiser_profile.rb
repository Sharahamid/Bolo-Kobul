class RenameColumnOfAdvertiserProfile < ActiveRecord::Migration[6.0]
  def change
    rename_column :advertiser_profiles, :license_number, :company_name
  end
end
