class CreateChatFriendships < ActiveRecord::Migration[6.0]
  def change
    create_table :chat_friendships do |t|
      t.integer :marriage_profile_id
      t.integer :chat_friend_id
      t.integer :status

      t.timestamps
    end
  end
end
