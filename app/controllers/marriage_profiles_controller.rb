class MarriageProfilesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_marriage_profile, only: [:edit_about, :update_about, :edit,
                                              :update, :profile_info, :show,
                                              :change_profile, :change_photo,
                                              :send_request, :accept_request,
                                              :cancel_request, :reject_request,
                                              :block_profile, :remove_profile,
                                              :unblock_profile, :switch,
                                              :dashboard, :search_page, :search]
  before_action :check_current_active_profile, :check_preference, except: [:new, :create]

  def index
    @marriage_profile = MarriageProfile.new
    render 'new'
  end

  def show
    render :profile_info
  end

  def dashboard
  end

  def profile_info
    if current_active_profile&.id != @marriage_profile.id && current_user
      key = "profile_views_#{@marriage_profile.id}"
      Rails.cache.write(key, (Rails.cache.read(key) || 0) + 1, expires_in: 8.days)
    end
  end

  def switch
    session[:marriage_profile_id] = @marriage_profile.id if @marriage_profile.present?
    redirect_to profile_info_marriage_profile_path(@marriage_profile)
  end

  def search_page
    @matches = SearchService.with_params(params, @marriage_profile.id)
  end

  def search
    @matches = SearchService.with_params(params, @marriage_profile.id)
  end

  def new
    @marriage_profile_count = current_user.marriage_profiles.count
    @max_marriage_profiles = ButterflyConfig.last.present? ?
                              ButterflyConfig.last.max_marriage_profiles : 5
    if @marriage_profile_count >= @max_marriage_profiles
      redirect_back fallback_location: root_path,
                    notice: 'You have already reached the maximum number of
                            profiles one can create for others!'
    else
      @marriage_profile = MarriageProfile.new
    end
  end

  def create
    @marriage_profile = current_user.marriage_profiles.build(marriage_profile_params)
    if @marriage_profile.save
      session[:marriage_profile_id] = @marriage_profile.id
      redirect_to new_partner_preference_path
    else
      render 'new'
    end
  end

  def edit_about
  end

  def update
    respond_to do |format|
      if @marriage_profile.update(marriage_profile_params)
        format.js { flash[:notice] = "Basic information updated successfully" }
      else
        format.js { flash[:notice] = "#{@marriage_profile.errors.full_messages.first}" }
      end
    end
  end

  def change_profile
    respond_to do |format|
      if @marriage_profile.update(marriage_profile_params)
        format.js { flash[:notice] = "Photo uploaded successfully!" }
      else
        format.js { flash[:notice] = "#{@marriage_profile.errors.full_messages.first}" }
      end
    end
  end

  def change_photo
    respond_to do |format|
      if @marriage_profile != current_active_profile
        format.js { flash[:notice] = "Permission denied!" }
      elsif @marriage_profile.update(params.require(:marriage_profile).permit(:photo_1, :photo_2, :photo_3, :profile_image))
        format.js { flash[:notice] = "Photo uploaded successfully!" }
      else
        format.js { flash[:notice] = "#{@marriage_profile.errors.full_messages.first}" }
      end
    end
  end

  # def change_profile
  #   respond_to do |format|
  #     if params[:profile_image].present?
  #       @marriage_profile.update(profile_image: params[:profile_image], crop_x: params[:crop_x], crop_y: params[:crop_y], crop_w: params[:crop_w], crop_h: params[:crop_h])
  #       p 'controller'
  #       p @marriage_profile.crop_x
  #       format.js { flash[:notice] = "Photo uploaded successfully!" }
  #     else
  #       format.js { flash[:notice] = "#{@marriage_profile.errors.full_messages.first}" }
  #     end
  #     # @marriage_profile = current_active_profile
  #     # format.js
  #     # format.html
  #   end
  # end

  def update_about
    respond_to do |format|
      if @marriage_profile.update(marriage_profile_params)
        format.js { flash[:notice] = "About yourself updated successfully" }
      else
        format.js { flash[:error] = "#{@marriage_profile.errors.full_messages.first}" }
      end
    end
  end

  def edit
  end

  def send_request

    if current_active_profile.friend_ids.include? @marriage_profile.id
      flash[:notice] = "You are already connected with each other!"
      redirect_back(fallback_location: "/") && return
    end

    if current_active_profile.has_bfly_for_profile_view?
      sending_request = current_active_profile.friend_request(@marriage_profile)
      if sending_request.present?
        current_active_profile.block_butterflies
        current_user.notifications.create(
          content: "Your 1st Kobul has been sent successfully. We will notify you as soon as they respond. <a href='#{profile_info_marriage_profile_path(@marriage_profile)}' style='color:#FFB627;font-weight:600;'>View Profile</a>",
          notifiable: @marriage_profile,
          will_email: false,
          will_sms: false
        )
        KobulOneMailer.with(user: current_user, profile: @marriage_profile).send_request.deliver_later
        SmsService.call(
          current_user.phone_number.to_s,
          "Your 1st Kobul has been sent! We will notify you as soon as they respond. Visit: www.bolokobul.com to see updates"
        )

        @marriage_profile.user.notifications.create(
          content: "A butterfly has fluttered your way! Someone is interested in getting to know you. <a href='#{profile_info_marriage_profile_path(current_active_profile)}' style='color:#FFB627;font-weight:600;'>See Who</a>",
          notifiable: @marriage_profile,
          will_email: false,
          will_sms: false
        )
        KobulOneMailer.with(user: @marriage_profile.user).receive_request.deliver_later
        SmsService.call(
          @marriage_profile.user.phone_number.to_s,
          "Good news! Someone has sent you a 1st Kobul. Log in to check their profile: #{profile_info_marriage_profile_path(current_active_profile)}"
        )
      end
      if current_active_profile.favourite_profile_ids.include?(@marriage_profile.id)
        Favourite.remove_from_favourite(@marriage_profile.id)
      end
      flash[:notice] = "Your 1st Kobul has been sent successfully"
      session[:butterfly] = "animate"
      redirect_back(fallback_location: "/")
    else
      flash[:danger] = "You don't have enough butterflies! You can purchase more."
      redirect_to new_order_path
    end
  end

  def accept_request
    friendship = Friendship.find_by(friendable: @marriage_profile, friend: current_active_profile) ||
                 Friendship.find_by(friendable: current_active_profile, friend: @marriage_profile)

    unless friendship.present?
      flash[:alert] = "No pending request"
      redirect_to dashboard_marriage_profile_path(current_active_profile) && return
    end

    unless current_active_profile.has_bfly_for_profile_view?
      flash[:danger] = "You don't have enough butterflies! You can purchase more."
      redirect_to new_order_path && return
    end

    friendship.accept! if friendship.respond_to?(:accept!)

      current_active_profile.use_butterflies
      @marriage_profile.use_with_blocked_butterflies if @marriage_profile.respond_to?(:use_with_blocked_butterflies)

      current_user.notifications.create(
        content: "You accepted a 1st Kobul! <a href='#{profile_info_marriage_profile_path(@marriage_profile)}' style='color:#FFB627;font-weight:600;'>View Their Profile</a>: #{@marriage_profile.unique_id}. Send 2nd Kobul to start chatting",
        notifiable: @marriage_profile,
        will_email: false,
        will_sms: false
      )

      KobulOneMailer.with(user: current_user, profile: @marriage_profile).accept_request.deliver_later
      SmsService.call(
        current_user.phone_number.to_s,
        "Check out the profile: #{profile_dashboard_url(@marriage_profile.unique_id)} and get to know more about your potential match!"
      )

      @marriage_profile.user.notifications.create(
        content: "Good news! #{current_active_profile.unique_id} has accepted your 1st Kobul! Send a 2nd Kobul to start chatting. <a href='#{profile_info_marriage_profile_path(@marriage_profile)}' style='color:#FFB627;font-weight:600;'>Check Their Profile</a>",
        notifiable: @marriage_profile,
        will_email: false,
        will_sms: false
      )

      KobulOneMailer.with(user: @marriage_profile.user, profile: current_active_profile).get_acceptance.deliver_later
      SmsService.call(
        @marriage_profile.user.phone_number.to_s,
        "Good News! Your 1st Kobul was accepted! Log in to view their full profile: #{profile_info_marriage_profile_path(@marriage_profile)}"
      )
     
      flash[:notice] = "Your 1st Kobul has been accepted successfully"
      redirect_to dashboard_marriage_profile_path(current_active_profile, butterfly: "animate")
  end

  def reject_request
    current_active_profile.decline_request(@marriage_profile)    
    @marriage_profile.unblock_blocked_butterflies if @marriage_profile.respond_to?(:unblock_blocked_butterflies)
    @marriage_profile.user.notifications.create(
      content: "Sorry, #{current_active_profile.unique_id} did not accept your 1st Kobul! Do not give up — keep exploring!",
      notifiable: @marriage_profile,
      will_email: false,
      will_sms: false
    )

    KobulOneMailer.with(user: @marriage_profile.user, profile: current_active_profile).get_rejection.deliver_later
    SmsService.call(
      @marriage_profile.user.phone_number.to_s,
      "🦋 Your 1st Kobul was not accepted this time. Do not give up — keep exploring www.bolokobul.com"
    )
    
    flash[:notice] = "1st Kobul rejected"
    redirect_to dashboard_marriage_profile_path(current_active_profile)
  end

  def cancel_request 
    current_active_profile.decline_request(@marriage_profile)
    current_active_profile.unblock_blocked_butterflies
    
    current_active_profile.user.notifications.create(
      content: "You have cancelled your 1st Kobul request to #{current_active_profile.unique_id}. Your butterfly is on its way back!",
      notifiable: @marriage_profile,
      will_email: false,
      will_sms: false 
    )
   
    flash[:notice] = "1st Kobul cancelled, but you got your butterfly back!"
    redirect_back(fallback_location: dashboard_marriage_profile_path(current_active_profile, butterfly: "bk_animate"))
  end

  def remove_profile
    current_active_profile.remove_friend(@marriage_profile)
  end

  def block_profile 
    if current_active_profile.friends_with?(@marriage_profile)
      current_active_profile.block_friend(@marriage_profile)
      flash[:notice] = "Blocked Successfully"
    end
    redirect_back fallback_location: root_path
  end

  def unblock_profile
    current_active_profile.unblock_friend(@marriage_profile)
    flash[:notice] = "Unblocked Successfully"
    redirect_back fallback_location: root_path
  end

  def requested_profiles
    @requested_profiles = current_active_profile.requested_friends
  end

  def pending_profiles
    @pending_profiles = current_active_profile.pending_friends
  end

  def accepted_profiles
    @accepted_profiles = current_active_profile.accepted_friends.where.not(status: :declined)
  end

  def blocked_profiles
    @blocked_profiles = current_active_profile.blocked_friends
  end

  def refferel_code
  end

  private

  def set_marriage_profile
    @marriage_profile = MarriageProfile.friendly.find(params[:id])
  end

  def marriage_profile_params
    params.require(:marriage_profile).permit(:name, :identification_document, :nid_or_passport, :gender,
                                             :date_of_birth, :religion, :hometown, :present_location, :present_address,
                                             :height_ft, :height_inch, :highest_education_level, :family_type, :blood_group,
                                             :photo_1, :photo_2, :photo_3, :family_values, :marital_status, :family_status,
                                             :profile_image, :about_my_self, :special_circumstances, :description)
  end

  def profile_dashboard_url(profile)
    "#{request.protocol + request.host_with_port}/marriage_profiles/#{profile.unique_id}/dashboard"
  end
end
