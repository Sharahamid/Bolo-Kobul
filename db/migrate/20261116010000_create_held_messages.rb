# Quiet hours (10 pm - 8 am Bangladesh time): phone notifications and texts that come up
# at night wait here and go out at 8 am (rake quiet_hours:release)
class CreateHeldMessages < ActiveRecord::Migration[8.1]
  def change
    create_table :held_messages do |t|
      t.string :channel, null: false      # "push" or "sms"
      t.integer :user_id                  # push: who gets it
      t.string :phone                     # sms: the number
      t.string :kind                      # sms: which message (for the admin switches)
      t.text :body                        # push: JSON payload; sms: the text
      t.timestamps
    end
    add_index :held_messages, :created_at
  end
end
