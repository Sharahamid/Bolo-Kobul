class AddColumnsToPrivacySettings < ActiveRecord::Migration[6.0]
  def change
    add_column :privacy_settings, :height_ft, :integer, default: 1
    add_column :privacy_settings, :physical_status, :integer, default: 1
    add_column :privacy_settings, :family_values, :integer, default: 1
    add_column :privacy_settings, :family_type, :integer, default: 1
    add_column :privacy_settings, :family_status, :integer, default: 1
    add_column :privacy_settings, :current_occupation, :integer, default: 1
  end
end
