class CreatePartnerRequests < ActiveRecord::Migration[6.0]
  def change
    create_table :partner_requests do |t|
      t.integer :sender_id
      t.integer :recipient_id
      t.integer :blocker_id
      t.integer :request_type
      t.integer :status

      t.timestamps
    end
  end
end
