# == Schema Information
#
# Table name: chat_room_users
#
#  id                  :bigint           not null, primary key
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  chat_room_id        :integer
#  marriage_profile_id :integer
#  last_read_at        :datetime
#  last_delivered_at   :datetime
#

class ChatRoomUser < ApplicationRecord
  #Associations
  belongs_to :marriage_profile
  belongs_to :chat_room

  # Message ticks, like WhatsApp: one grey tick = sent, two grey = delivered to the
  # other person's phone or browser, two blue = read
  def self.tick_status(message, other)
    return :read if other&.last_read_at && message.created_at <= other.last_read_at
    return :delivered if other&.last_delivered_at && message.created_at <= other.last_delivered_at

    :sent
  end

  def receipt
    { profile_id: marriage_profile_id,
      delivered_at: last_delivered_at&.utc&.iso8601(3),
      read_at: last_read_at&.utc&.iso8601(3) }
  end

  # Tells the open chat window of the other person to update its ticks
  def broadcast_receipt
    ActionCable.server.broadcast "room_#{chat_room_id}_channel", receipt: receipt
  end
end
