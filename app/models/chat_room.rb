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

  # Messages from the other person this profile has not seen yet
  def unread_count_for(profile)
    last_read = chat_room_users.find_by(marriage_profile_id: profile.id)&.last_read_at
    scope = messages.where.not(sender_id: profile.id)
    scope = scope.where('messages.created_at > ?', last_read) if last_read
    scope.count
  end

  # Reading a chat also counts as delivered. The sender's open chat turns its ticks blue.
  def mark_read!(profile)
    member = chat_room_users.find_by(marriage_profile_id: profile.id)
    return unless member

    unseen = messages.where.not(sender_id: profile.id)
    unseen = unseen.where('messages.created_at > ?', member.last_read_at) if member.last_read_at
    news = unseen.exists?
    now = Time.current
    member.update_columns(last_read_at: now, last_delivered_at: now)
    member.broadcast_receipt if news
  end

  # The member's phone or browser is connected, so every message waiting for them has
  # reached them (two grey ticks). Only chats with something new are touched.
  def self.mark_delivered_for!(user)
    now = Time.current
    ChatRoomUser.where(marriage_profile_id: user.marriage_profiles.select(:id))
                .where('EXISTS (SELECT 1 FROM messages m WHERE m.chat_room_id = chat_room_users.chat_room_id ' \
                       'AND m.sender_id <> chat_room_users.marriage_profile_id ' \
                       'AND m.created_at > COALESCE(chat_room_users.last_delivered_at, chat_room_users.last_read_at, \'1970-01-01\'))')
                .find_each do |member|
      member.update_columns(last_delivered_at: now)
      member.broadcast_receipt
    end
  end

  def connected_profile(current_profile)
    marriage_profiles.where.not(id: current_profile.id).first
  end


end
