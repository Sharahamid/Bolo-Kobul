class CreateNotifications < ActiveRecord::Migration[6.0]
  def change
    create_table :notifications do |t|
      t.integer :notifiable_id
      t.string :notifiable_type
      t.boolean :is_read
      t.integer :recipient_id
      t.integer :sender_id

      t.timestamps
    end
  end
end
