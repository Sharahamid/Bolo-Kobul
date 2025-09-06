class AddPresentAddressToMarriageProfile < ActiveRecord::Migration[6.0]
  def change
    add_column :marriage_profiles, :present_address, :text
  end
end
