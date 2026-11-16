# WhatsApp-style reactions on chat messages: one emoji per member per message
class CreateMessageReactions < ActiveRecord::Migration[8.1]
  def change
    create_table :message_reactions do |t|
      t.integer :message_id, null: false
      t.integer :marriage_profile_id, null: false
      t.string :emoji, null: false, limit: 16
      t.timestamps
    end
    add_index :message_reactions, %i[message_id marriage_profile_id], unique: true
    add_index :message_reactions, :updated_at
  end
end
