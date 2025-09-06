# == Schema Information
#
# Table name: chat_rooms
#
#  id         :bigint           not null, primary key
#  chat_type  :integer
#  is_private :boolean          default(FALSE)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ChatRoom < ApplicationRecord
  #Associations
  has_many :chat_room_users, dependent: :destroy
  has_many :marriage_profiles, through: :chat_room_users
  has_many :messages, dependent: :destroy

  def self.get_private_chat_room(user, current_user)

    user_chat_rooms = user.chat_rooms.where(is_private: true)
    if user_chat_rooms.present?
      chat_room_user_ids = user_chat_rooms.map(&:id)
    end


    if user_chat_rooms.present?
      current_user_chat_rooms = current_user.chat_room_users.where(chat_room_id: chat_room_user_ids)

      if current_user_chat_rooms.present?

        current_user_chat_rooms.first.chat_room
      else
        chat_room = ChatRoom.create!(is_private: true)
        chat_room_users = ChatRoomUser.create!(marriage_profile_id: user.id, chat_room_id: chat_room.id)
        current_user_chat_room = ChatRoomUser.create!(marriage_profile_id: current_user.id, chat_room_id: chat_room.id)
        return chat_room
      end

    else
      chat_room = ChatRoom.create!(is_private: true)
      chat_room_user = ChatRoomUser.create!(marriage_profile_id: user.id, chat_room_id: chat_room.id)
      current_user_chat_room = ChatRoomUser.create!(marriage_profile_id: current_user.id, chat_room_id: chat_room.id)
      return chat_room
    end
  end

  def connected_profile(current_profile)
    marriage_profiles.where.not(id: current_profile.id).first
  end


end
