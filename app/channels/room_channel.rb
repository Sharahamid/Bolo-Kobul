class RoomChannel < ApplicationCable::Channel
  # Only members of the chat room may listen to it
  def subscribed
    room = chat_room
    if room && ChatRoomUser.where(chat_room_id: room.id, marriage_profile_id: current_user.marriage_profiles.select(:id)).exists?
      stream_from "room_#{room.id}_channel"
    else
      reject
    end
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  private

  def chat_room
    ChatRoom.find_by(id: params[:chat_room_id])
  end

end
