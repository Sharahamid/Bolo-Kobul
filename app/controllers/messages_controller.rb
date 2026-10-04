class MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :take_chat_rooms, only: [:index, :profile]

  def index
    if @chat_rooms.present?
      @message = Message.new
    else
      flash[:warning] = "Your chatting option will be open after you send 2 Kobuls to a profile you like, and they accept it"
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
    # Only allow posting into chat rooms the sender is a member of
    unless current_active_profile.chat_rooms.exists?(id: message_params[:chat_room_id])
      head :forbidden and return
    end
    respond_to do |format|
      if message_params[:body].present? && @message.save!
        chat_room = @message.chat_room
        # The chat window inserts the body as HTML, so send it escaped: a message
        # can never run code in the other person's browser
        ActionCable.server.broadcast "room_#{chat_room.id}_channel",
                                     content: @message.as_json.merge('body' => ERB::Util.html_escape(@message.body.to_s))
        notify_chat_recipients(chat_room)

        format.js
      else
        format.js
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end

  def show
    @message = Message.where(chat_room_id: current_active_profile.chat_rooms.select(:id)).find(params[:id])
  end

  private

  # Tells the other person in the chat about a new message. The message itself is never
  # included, so nothing private shows on a lock screen, in an inbox or in an SMS.
  # - phone notification: at most one per chat every 5 minutes
  # - site notification, email and SMS: at most one per chat every 30 minutes
  def notify_chat_recipients(chat_room)
    sender = current_active_profile
    recipient_profile_ids = chat_room.chat_room_users.where.not(marriage_profile_id: sender.id).pluck(:marriage_profile_id)
    MarriageProfile.where(id: recipient_profile_ids).includes(:user).each do |recipient_profile|
      user = recipient_profile.user
      next if user.nil? || user.id == current_user.id

      if WebPushService.configured? &&
         Rails.cache.write("push_chat_#{chat_room.id}_#{user.id}", true, expires_in: 5.minutes, unless_exist: true)
        WebPushJob.perform_later(user.id, {
          'title' => 'Bolo Kobul',
          'body' => 'You have a new message. Tap to read it.',
          'url' => profile_message_path(sender),
          'tag' => "chat-#{chat_room.id}"
        })
      end

      next unless Rails.cache.write("alert_chat_#{chat_room.id}_#{user.id}", true, expires_in: 30.minutes, unless_exist: true)

      user.notifications.create(
        content: "You have a new message from #{sender.unique_id}. <a href='#{profile_message_path(sender)}' style='color:#FFB627;font-weight:600;'>Read and Reply</a>",
        notifiable: recipient_profile,
        will_email: false,
        will_sms: false,
        skip_push: true
      )
      ChatMessageAlertJob.perform_later(user.id, sender.id, profile_message_url(sender))
    end
  rescue StandardError => e
    Rails.logger.warn("[Chat] message alert failed: #{e.message}")
  end

  def take_chat_rooms
    @chat_rooms = current_active_profile.chat_rooms.includes(:messages)
  end

  def message_params
    # sender_id is always the current profile and is never taken from the form
    params.require(:message).permit(:body, :chat_room_id, :recipient_id)
  end
end
