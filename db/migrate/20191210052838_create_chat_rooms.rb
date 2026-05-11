class CreateChatRooms < ActiveRecord::Migration[6.0]
  def change
    create_table :chat_rooms do |t|
      t.integer :chat_type

      t.timestamps
    end
  end
end
