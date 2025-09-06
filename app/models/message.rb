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
end
