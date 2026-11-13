# == Schema Information
#
# Table name: messages
#
#  id           :bigint           not null, primary key
#  body         :text
#  status       :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  chat_room_id :integer
#  recipient_id :integer
#  sender_id    :integer
#

class Message < ApplicationRecord
  # Associations
  belongs_to :chat_room
  belongs_to :marriage_profile, foreign_key: :sender_id
  # The message this one replies to (WhatsApp-style quote above the text)
  belongs_to :reply_to, class_name: 'Message', optional: true

  QUOTE_LENGTH = 120

  # Short version of the text, shown in the quote of a reply
  def quote_text
    body.to_s.squish.truncate(QUOTE_LENGTH)
  end
end
