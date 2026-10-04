# When a member's phone or browser last received the messages in a chat (the second
# grey tick, like WhatsApp). last_read_at is the blue ticks.
class AddLastDeliveredAtToChatRoomUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :chat_room_users, :last_delivered_at, :datetime, if_not_exists: true
  end
end
