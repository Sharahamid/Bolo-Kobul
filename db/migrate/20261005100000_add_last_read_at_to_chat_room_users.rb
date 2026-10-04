class AddLastReadAtToChatRoomUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :chat_room_users, :last_read_at, :datetime
  end
end
