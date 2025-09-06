class CreateChatRoomUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :chat_room_users do |t|
      t.integer :marriage_profile_id
      t.integer :chat_room_id

      t.timestamps
    end
  end
end
