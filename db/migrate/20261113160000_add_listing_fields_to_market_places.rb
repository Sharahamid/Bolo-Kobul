# Businesses can now apply online for the Wedding Shopping List (/advertise), pay the
# listing fee and wait for admin approval. Listings end after one year.
class AddListingFieldsToMarketPlaces < ActiveRecord::Migration[8.1]
  def change
    add_column :market_places, :contact_name, :string
    add_column :market_places, :contact_phone, :string
    add_column :market_places, :contact_email, :string
    add_column :market_places, :submitted_online, :boolean, default: false, null: false
    add_column :market_places, :paid_at, :datetime
    add_column :market_places, :listed_until, :datetime
    add_column :market_places, :reminder_sent_at, :datetime
    add_column :orders, :market_place_id, :bigint
    add_index :orders, :market_place_id
  end
end
