class ChatFriendshipsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_marriage_profile


  def send_request
    if current_active_profile&.chat_friendships&.where(status:1).map(&:chat_friend_id)&.include?(@marriage_profile.id)
      flash[:notice] = "You already send a request to chat with each other!"
      redirect_back(fallback_location: "/") && return
    end

    if current_active_profile.has_bfly_for_chatting?
      sending_request = current_active_profile.friend_chat_request(@marriage_profile)
      if sending_request.present?
        current_active_profile.block_butterflies_chat
        @marriage_profile.user.notifications
          .create(
            content: "#{current_active_profile.unique_id} would like to learn more about you. Check out all available information and begin chatting",
            notifiable: @marriage_profile,
            will_email: false,
            will_sms: false
          )
        KobulTwoMailer.with(current_profile: current_active_profile, profile: @marriage_profile).send_request.deliver_later
        SmsService.call(
          @marriage_profile.user.phone_number.to_s,
          "A prospect would like to chat with you. Send them a butterfly if you are interested #{profile_dashboard_url(current_active_profile)}"
        )
      end
      flash[:notice] = "Butterfly request send successfully for kobul-2."
      session[:butterfly] = "animate"
      redirect_back(fallback_location: "/")
    else
      flash[:danger] = "You don't have enough butterflies or they are in use!"
      redirect_to new_order_path
    end
  end

  def accept_request
    if current_active_profile&.chat_friendships&.where(status:2)&.map(&:chat_friend_id)&.include?(@marriage_profile.id)
      flash[:notice] = "You are already in chat with each other!"
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
            content: "#{current_active_profile.unique_id} has accepted your proposal to chat with you! Best of Luck! <3",
            notifiable: @marriage_profile,
            will_email: false,
            will_sms: false
          )

        current_user.notifications
                    .create(
                      content: "Begin chatting with #{@marriage_profile.unique_id}! Your name or number will still not be disclosed.",
                      notifiable: current_active_profile,
                      will_email: false,
                      will_sms: false
                    )

        KobulTwoMailer.with(current_user: current_user, profile: @marriage_profile).accept_request.deliver_later
        SmsService.call(
          @current_user.phone_number.to_s,
          "Begin chatting with your potential prospect #{profile_dashboard_url(@marriage_profile)}"
        )

        KobulTwoMailer.with(current_profile: current_active_profile, profile: @marriage_profile).get_acceptance.deliver_later
        SmsService.call(
          @marriage_profile.user.phone_number.to_s,
          "Your special one has accepted your butterfly to chat with you. Click #{profile_dashboard_url(current_active_profile)}"
        )
      end
      flash[:notice] = "Request for kobul-2 accepted successfully."
      redirect_to profile_message_path(@marriage_profile,
                                       butterfly: "animate")
    else
      flash[:danger] = "You don't have enough butterflies or they are in use!"
      redirect_to new_order_path
    end
  end

  def reject_request
    cancel_request = current_active_profile.decline_chat_request(@marriage_profile)
    if cancel_request.present?
      @marriage_profile.unblock_blocked_butterflies_chat
      @marriage_profile.user.notifications.create(
        content: "#{current_active_profile.unique_id} did not accept your butterfly!",
        notifiable: @marriage_profile,
        will_email: false,
        will_sms: false
      )

      KobulTwoMailer.with(current_profile: current_active_profile, profile: @marriage_profile).get_rejection.deliver_later
      SmsService.call(
        @marriage_profile.user.phone_number.to_s,
        "A butterfly was not accepted. Find more profiles at bolokobul.com"
      )
    end
    flash[:notice] = "kobul (2) request cancelled "
    redirect_to dashboard_marriage_profile_path(current_active_profile)
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
