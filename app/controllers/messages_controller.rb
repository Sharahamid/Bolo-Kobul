class MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :take_chat_rooms, only: [:index, :profile]

  def index
    if @chat_rooms.present?
      @message = Message.new
    else
      flash[:warning] = "Your chatting option will be open after you like a profile and the person likes yours."
      redirect_back fallback_location: root_path
    end
  end

  def profile
    respond_to do |format|
      @marriage_profile = MarriageProfile.friendly.find(params[:id])
      @chat_room = ChatRoom.get_private_chat_room(@marriage_profile, current_active_profile)
      @messages = Message.includes(:chat_room, :marriage_profile).where(chat_room_id: @chat_room.id).order(created_at: :asc)
      @message = Message.new
      format.html
      format.js
    end
  end

  def new
    @message = Message.new
  end

  def create
    @message = current_active_profile.messages.build(message_params)
    respond_to do |format|
      if message_params[:body].present? && @message.save!
        chat_room = @message.chat_room
        ActionCable.server.broadcast "room_#{chat_room.id}_channel",
                                     content: @message

        format.js
      else
        format.js
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end

  def show
    @message = Message.find_by(id: params[:id])
  end

  private

  def take_chat_rooms
    @chat_rooms = current_active_profile.chat_rooms.includes(:messages)
  end

  def message_params
    params.require(:message).permit(:body, :chat_room_id, :sender_id, :recipient_id)
  end
end