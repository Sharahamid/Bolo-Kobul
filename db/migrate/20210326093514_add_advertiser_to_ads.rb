class AddAdvertiserToAds < ActiveRecord::Migration[6.0]
  def change
    add_column :ads, :advertiser, :string
  end
end
