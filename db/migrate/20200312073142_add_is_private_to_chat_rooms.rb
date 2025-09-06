class AddIsPrivateToChatRooms < ActiveRecord::Migration[6.0]
  def change
    add_column :chat_rooms, :is_private, :boolean, default: false
  end
end
