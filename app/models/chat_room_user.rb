# == Schema Information
#
# Table name: chat_room_users
#
#  id                  :bigint           not null, primary key
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  chat_room_id        :integer
#  marriage_profile_id :integer
#

class ChatRoomUser < ApplicationRecord
  #Associations
  belongs_to :marriage_profile
  belongs_to :chat_room
end
