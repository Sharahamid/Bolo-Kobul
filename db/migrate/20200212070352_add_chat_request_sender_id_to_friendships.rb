class AddChatRequestSenderIdToFriendships < ActiveRecord::Migration[6.0]
  def change
    add_column :friendships, :chat_request_sender_id, :integer
  end
end
