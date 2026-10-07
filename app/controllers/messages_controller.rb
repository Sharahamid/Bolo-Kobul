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
    @marriage_profile = MarriageProfile.friendly.find(params[:id])
    # Chatting opens only after both 2nd Kobuls are accepted
    unless current_active_profile&.chat_friendships&.exists?(chat_friend_id: @marriage_profile.id, status: 2)
      flash[:warning] = "Your chatting option will be open after you send 2 Kobuls to a profile you like, and they accept it"
      return redirect_to(profile_info_marriage_profile_path(@marriage_profile))
    end

    respond_to do |format|
      @chat_room = ChatRoom.get_private_chat_room(@marriage_profile, current_active_profile)
      @chat_room.mark_read!(current_active_profile)
      @messages = Message.includes(:chat_room, :marriage_profile).where(chat_room_id: @chat_room.id).order(created_at: :asc)
      @message = Message.new
      format.html
      format.js
    end
  end

  # The open chat window saw a new message arrive live
  def read
    chat_room = current_active_profile&.chat_rooms&.find_by(id: params[:chat_room_id])
    return head(:not_found) unless chat_room

    chat_room.mark_read!(current_active_profile)
    head :no_content
  end

  def create
    @message = current_active_profile.messages.build(message_params)
    # Only allow posting into chat rooms the sender is a member of
    chat_room = current_active_profile.chat_rooms.find_by(id: message_params[:chat_room_id])
    head :forbidden and return unless chat_room
    # No messages to or from a blocked member
    other = chat_room.connected_profile(current_active_profile)
    head :forbidden and return if other && current_active_profile.blocked_with?(other)
    respond_to do |format|
      if message_params[:body].present? && @message.save!
        chat_room = @message.chat_room
        # The chat window inserts the body as HTML, so send it escaped: a message
        # can never run code in the other person's browser
        ActionCable.server.broadcast "room_#{chat_room.id}_channel",
                                     { content: @message.as_json.merge('body' => ERB::Util.html_escape(@message.body.to_s)) }
        notify_chat_recipients(chat_room)
        chat_room.mark_read!(current_active_profile)

        format.js
      else
        format.js
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  # Tells the other person in the chat about a new message. The message itself is never
  # included, so nothing private shows on a lock screen or in an inbox.
  # - phone notification (with sound and vibration): at most one per chat every 30 seconds
  # - site notification and email: at most one per chat every 30 minutes
  def notify_chat_recipients(chat_room)
    sender = current_active_profile
    recipient_profile_ids = chat_room.chat_room_users.where.not(marriage_profile_id: sender.id).pluck(:marriage_profile_id)
    MarriageProfile.where(id: recipient_profile_ids).includes(:user).each do |recipient_profile|
      user = recipient_profile.user
      next if user.nil? || user.id == current_user.id

      # Live alert on whatever page they have open (sound, vibration, banner)
      AlertsChannel.broadcast_to(user, { kind: 'message', from: sender.unique_id,
                                         url: profile_message_path(sender), chat_room_id: chat_room.id })

      if WebPushService.configured? &&
         Rails.cache.write("push_chat_#{chat_room.id}_#{user.id}", true, expires_in: 30.seconds, unless_exist: true)
        WebPushJob.perform_later(user.id, {
          'title' => 'Bolo Kobul',
          'body' => I18n.with_locale(user.locale.presence_in(%w[en bn]) || :en) { I18n.t('push.new_message') },
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
    blocked_ids = HasFriendship::Friendship.where(friendable_type: 'MarriageProfile', friendable_id: current_active_profile.id, status: 3).select(:friend_id)
    blocked_room_ids = ChatRoomUser.where(marriage_profile_id: blocked_ids).select(:chat_room_id)
    @chat_rooms = current_active_profile.chat_rooms.where.not(id: blocked_room_ids).includes(:messages)
  end

  def message_params
    # sender_id is always the current profile and is never taken from the form
    params.require(:message).permit(:body, :chat_room_id, :recipient_id)
  end
end
