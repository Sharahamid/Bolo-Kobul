class RoomChannel < ApplicationCable::Channel
  def subscribed
    stream_from "room_#{params[:chat_room_id]}_channel"
    # stream_for chat_room
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  private

  def chat_room
    puts "\n"*8
    p params[:chat_room]
    puts "\n"*8
    ChatRoom.find_by(id: params[:chat_room_id])
  end

end
