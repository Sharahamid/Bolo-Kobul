class ChatFriendshipsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_marriage_profile, except: [:pending_chat_profiles]

  def send_request
    if current_active_profile&.chat_friendships&.where(status:1).map(&:chat_friend_id)&.include?(@marriage_profile.id)
      flash[:notice] = "You are already connected to chat!"
      redirect_back(fallback_location: "/") && return
    end

    if current_active_profile.has_bfly_for_chatting?
      sending_request = current_active_profile.friend_chat_request(@marriage_profile)
      if sending_request.present?
        current_active_profile.block_butterflies_chat
        @marriage_profile.user.notifications
          .create(
            content: "#{current_active_profile.unique_id} would like to chat with you. <a href='#{profile_info_marriage_profile_path(current_active_profile)}' style='color:#FFB627;font-weight:600;'>Check out their Profile</a> and begin chatting",
            notifiable: @marriage_profile,
            will_email: false,
            will_sms: false
          )
        KobulTwoMailer.with(current_profile: current_active_profile, profile: @marriage_profile).send_request.deliver_later
        SmsService.call(
          @marriage_profile.user.phone_number.to_s,
          "Someone has sent you a 2nd Kobul and wants to chat! Log in to respond: #{profile_dashboard_url(current_active_profile)}"
        )
      end
      flash[:notice] = "Your 2nd Kobul has been sent successfully"
      session[:butterfly] = "animate"
      redirect_back(fallback_location: "/")
    else
      flash[:danger] = "You don't have enough butterflies! You can purchase more."
      redirect_to new_order_path
    end
  end

  def accept_request
    if current_active_profile&.chat_friendships&.where(status:2)&.map(&:chat_friend_id)&.include?(@marriage_profile.id)
      flash[:notice] = "You are already connected to chat!"
      redirect_back(fallback_location: "/") && return
    end

    if current_active_profile.has_bfly_for_chatting?
      accept_request = current_active_profile.accept_chat_request(@marriage_profile)
      if accept_request.present?
        ChatRoom.get_private_chat_room(@marriage_profile, current_active_profile)
        current_active_profile.use_butterflies_chat
        @marriage_profile.use_with_blocked_butterflies_chat
        @marriage_profile.user.notifications
          .create(
            content: "#{current_active_profile.unique_id} has accepted your 2nd Kobul. You can now <a href='#{profile_message_path(current_active_profile)}' style='color:#FFB627;font-weight:600;'>Begin Chatting</a> safely! Best of Luck! <3",
            notifiable: @marriage_profile,
            will_email: false,
            will_sms: false
          )

        current_user.notifications
                    .create(
                      content: "<a href='#{profile_message_path(@marriage_profile)}' style='color:#FFB627;font-weight:600;'>Start Chatting</a> with #{@marriage_profile.unique_id}! Your name or number will still not be disclosed.",
                      notifiable: current_active_profile,
                      will_email: false,
                      will_sms: false
                    )

        KobulTwoMailer.with(current_user: current_user, profile: @marriage_profile).accept_request.deliver_later
        SmsService.call(
          @current_user.phone_number.to_s,
          "You can now start chatting safely with #{profile_dashboard_url(@marriage_profile.unique_id)}. Your name or number will still not be disclosed."
        )

        KobulTwoMailer.with(current_profile: current_active_profile, profile: @marriage_profile).get_acceptance.deliver_later
        SmsService.call(
          @marriage_profile.user.phone_number.to_s,
          "Congratulations! Your 2nd Kobul was accepted. Log in and start chatting now: #{profile_dashboard_url(@marriage_profile.unique_id)}"
        )
      end
      flash[:notice] = "Your 2nd Kobul has been accepted successfully"
      redirect_to profile_message_path(@marriage_profile,
                                       butterfly: "animate")
    else
      flash[:danger] = "You don't have enough butterflies! You may purchase more"
      redirect_to new_order_path
    end
  end

  def reject_request 
    current_active_profile.decline_chat_request(@marriage_profile)
    @marriage_profile.unblock_blocked_butterflies_chat
    Friendship.where(
      '(friendable_id = ? AND friend_id = ?) OR (friendable_id = ? AND friend_id = ?)',
      current_active_profile.id, @marriage_profile.id,
      @marriage_profile.id, current_active_profile.id
    ).destroy_all
    @marriage_profile.user.notifications.create(
      content: "#{current_active_profile.unique_id} did not accept your 2nd Kobul! Keep exploring — the right match is out there!",
      notifiable: @marriage_profile,
      will_email: false,
      will_sms: false
    )

    current_user.notifications.create(
      content: "You have declined #{@marriage_profile.unique_id}'s 2nd Kobul request. Keep exploring other profiles.",
      notifiable: current_active_profile,
      will_email: false,
      will_sms: false
    )

    KobulTwoMailer.with(current_profile: current_active_profile, profile: @marriage_profile).get_rejection.deliver_later
    SmsService.call(
      @marriage_profile.user.phone_number.to_s,
      "Your 2nd Kobul was not accepted this time. Keep exploring — the right match is out there: www.bolokobul.com"
    )
    
    flash[:notice] = "2nd Kobul Cancelled. Check out more profiles!"
    redirect_to dashboard_marriage_profile_path(current_active_profile)
  end

  def pending_chat_profiles
    @pending_chat_profiles = ChatFriendship
                               .where(chat_friend_id: current_active_profile.id, status: 1)
                               .map(&:marriage_profile)
  end

  private

  def set_marriage_profile
    @marriage_profile = MarriageProfile.friendly.find(params[:id])
  end

  def chat_friendship_params
    params.require(:chat_friendship).permit!
  end

  def profile_dashboard_url(profile)
    "#{request.protocol + request.host_with_port}/marriage_profiles/#{profile.unique_id}/dashboard"
  end
end
