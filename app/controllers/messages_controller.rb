class MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :take_chat_rooms, only: [:index, :profile]

  def index
    if @chat_rooms.present?
      @message = Message.new
    else
      # No chats yet: explain how chat opens and offer a next step
      render :empty
    end
  end

  def profile
    @marriage_profile = MarriageProfile.friendly.find(params[:id])
    if current_active_profile&.blocked_with?(@marriage_profile)
      flash[:warning] = current_active_profile.blocked_by_me?(@marriage_profile) ?
        I18n.t('chat.closed_you_blocked', id: @marriage_profile.unique_id) : I18n.t('chat.closed_blocked')
      return redirect_to(messages_path)
    end
    # Chatting opens only after both 2nd Kobuls are accepted
    unless current_active_profile&.chat_friendships&.exists?(chat_friend_id: @marriage_profile.id, status: 2)
      flash[:warning] = "Your chatting option will be open after you send 2 Kobuls to a profile you like, and they accept it"
      return redirect_to(profile_info_marriage_profile_path(@marriage_profile))
    end

    respond_to do |format|
      @chat_room = ChatRoom.get_private_chat_room(@marriage_profile, current_active_profile)
      # Opening the chat reads everything from this person (older data can have two rooms)
      shared_rooms = ChatRoom.shared_rooms(@marriage_profile, current_active_profile).to_a
      shared_rooms.each { |room| room.mark_read!(current_active_profile) }
      @messages = Message.includes(:chat_room, :marriage_profile, reply_to: :marriage_profile).where(chat_room_id: shared_rooms.map(&:id)).order(created_at: :asc)
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

  # Messages newer than the last one on screen. The open chat asks for these when the live
  # connection is down or was asleep (phone screen off), so nothing is ever missed.
  def since
    chat_room = current_active_profile&.chat_rooms&.find_by(id: params[:chat_room_id])
    return head(:not_found) unless chat_room

    other = chat_room.connected_profile(current_active_profile)
    room_ids = other ? ChatRoom.shared_rooms(other, current_active_profile).pluck(:id) : [chat_room.id]
    news = Message.where(chat_room_id: room_ids).where('messages.id > ?', params[:after_id].to_i)
                  .includes(:reply_to).order(:id).limit(100)
    chat_room.mark_read!(current_active_profile) if news.any? { |m| m.sender_id != current_active_profile.id }
    render json: news.map { |m|
      m.as_json.merge('body' => ERB::Util.html_escape(m.body.to_s), 'reply' => reply_json(m.reply_to))
    }
  end

  def create
    @message = current_active_profile.messages.build(message_params.except(:reply_to_id))
    # Only allow posting into chat rooms the sender is a member of
    chat_room = current_active_profile.chat_rooms.find_by(id: message_params[:chat_room_id])
    head :forbidden and return unless chat_room
    # No messages to or from a blocked member
    other = chat_room.connected_profile(current_active_profile)
    head :forbidden and return if other && current_active_profile.blocked_with?(other)
    # A reply can only quote a message from the same chat
    if message_params[:reply_to_id].present?
      @message.reply_to = chat_room.messages.find_by(id: message_params[:reply_to_id])
    end
    respond_to do |format|
      if message_params[:body].present? && @message.save!
        chat_room = @message.chat_room
        # The chat window inserts the body as HTML, so send it escaped: a message
        # can never run code in the other person's browser
        ActionCable.server.broadcast "room_#{chat_room.id}_channel",
                                     { content: @message.as_json.merge('body' => ERB::Util.html_escape(@message.body.to_s),
                                                                       'reply' => reply_json(@message.reply_to)) }
        notify_chat_recipients(chat_room)
        chat_room.mark_read!(current_active_profile)

        # The page shows the message itself (live, or by asking for new messages)
        format.js { head :ok }
        format.json { head :ok }
      else
        format.js { head :unprocessable_entity }
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

  # The quoted message for the live chat; text escaped like the message itself
  def reply_json(original)
    return nil unless original

    { 'id' => original.id, 'sender_id' => original.sender_id, 'text' => ERB::Util.html_escape(original.quote_text) }
  end

  def take_chat_rooms
    blocked_ids = HasFriendship::Friendship.where(friendable_type: 'MarriageProfile', friendable_id: current_active_profile.id, status: 3).select(:friend_id)
    blocked_room_ids = ChatRoomUser.where(marriage_profile_id: blocked_ids).select(:chat_room_id)
    @chat_rooms = current_active_profile.active_chat_rooms.where.not(id: blocked_room_ids).includes(:messages)
  end

  def message_params
    # sender_id is always the current profile and is never taken from the form
    params.require(:message).permit(:body, :chat_room_id, :recipient_id, :reply_to_id)
  end
end
