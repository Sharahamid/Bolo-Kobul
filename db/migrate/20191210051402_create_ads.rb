class CreateAds < ActiveRecord::Migration[6.0]
  def change
    create_table :ads do |t|
      t.integer :advertiser_profile_id
      t.integer :ad_location_id
      t.string :title
      t.string :url

      t.timestamps
    end
  end
end
