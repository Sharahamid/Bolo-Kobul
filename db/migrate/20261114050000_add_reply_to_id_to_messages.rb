# Replying to one chat message, like WhatsApp: the reply remembers which message it answers
class AddReplyToIdToMessages < ActiveRecord::Migration[8.1]
  def change
    add_column :messages, :reply_to_id, :integer
    add_index :messages, :reply_to_id
  end
end
