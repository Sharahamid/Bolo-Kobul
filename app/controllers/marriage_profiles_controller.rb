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
        format.js { flash[:notice] = "Basic information updated successfully." }
      else
        format.js { flash[:notice] = "#{@marriage_profile.errors.full_messages.first}" }
      end
    end
  end

  def change_profile
    respond_to do |format|
      if @marriage_profile.update(marriage_profile_params)
        format.js { flash[:notice] = "Successfully uploaded your profile picture!" }
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
        format.js { flash[:notice] = "Successfully uploaded your profile picture!" }
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
  #       format.js { flash[:notice] = "Successfully uploaded your profile picture!" }
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
        format.js { flash[:notice] = "About yourself updated successfully." }
      else
        format.js { flash[:error] = "#{@marriage_profile.errors.full_messages.first}" }
      end
    end
  end

  def edit
  end

  def send_request

    if current_active_profile.friend_ids.include? @marriage_profile.id
      flash[:notice] = "You are already in friends with each other!"
      redirect_back(fallback_location: "/") && return
    end

    if current_active_profile.has_bfly_for_profile_view?
      sending_request = current_active_profile.friend_request(@marriage_profile)
      if sending_request.present?
        current_active_profile.block_butterflies
        current_user.notifications.create(
          content: "Your butterfly has been sent successfully",
          notifiable: @marriage_profile,
          will_email: false,
          will_sms: false
        )
        KobulOneMailer.with(user: current_user, profile: @marriage_profile).send_request.deliver_later
        SmsService.call(
          current_user.phone_number.to_s,
          "Your butterfly has been sent successfully! Visit: www.bolokobul.com"
        )

        @marriage_profile.user.notifications.create(
          content: "A butterfly has fluttered your way! Check out the profile who has shown interest",
          notifiable: @marriage_profile,
          will_email: false,
          will_sms: false
        )
        KobulOneMailer.with(user: @marriage_profile.user).receive_request.deliver_later
        SmsService.call(
          @marriage_profile.user.phone_number.to_s,
          "Someone wants to know you better! To know your prospect, check #{profile_dashboard_url(@marriage_profile)}"
        )
      end
      if current_active_profile.favourite_profile_ids.include?(@marriage_profile.id)
        Favourite.remove_from_favourite(@marriage_profile.id)
      end
      flash[:notice] = "Your butterfly has been sent successfully"
      session[:butterfly] = "animate"
      redirect_back(fallback_location: "/")
    else
      flash[:danger] = "You don't have enough butterflies or they are in use!"
      redirect_to new_order_path
    end
  end

  def accept_request
    if current_active_profile.friend_ids.include? @marriage_profile.id
      flash[:notice] = "You are already in friends with each other!"
      redirect_back(fallback_location: "/") && return
    end

    if current_active_profile.has_bfly_for_profile_view?
      accept_request = current_active_profile.accept_request(@marriage_profile)
      if accept_request.present?
        current_active_profile.use_butterflies
        @marriage_profile.use_with_blocked_butterflies
        current_user.notifications.create(
          content: "Learn more about #{@marriage_profile.unique_id}. Send them a butterfly if you are interested to proceed",
          notifiable: @marriage_profile,
          will_email: false,
          will_sms: false
        )
        KobulOneMailer.with(user: current_user, profile: @marriage_profile).accept_request.deliver_later
        SmsService.call(
          current_user.phone_number.to_s,
          "Learn more about your potential prospect #{profile_dashboard_url(@marriage_profile)}"
        )

        @marriage_profile.user.notifications.create(
          content: "#{current_active_profile.unique_id} has accepted your butterfly! Check more details on their profile",
          notifiable: @marriage_profile,
          will_email: false,
          will_sms: false
        )
        KobulOneMailer.with(user: @marriage_profile.user, profile: current_active_profile).get_acceptance.deliver_later
        SmsService.call(
          @marriage_profile.user.phone_number.to_s,
          "The one you wanted to know more has responded. To know more about your potential prospect, visit #{profile_dashboard_url(@marriage_profile)}"
        )
      end
      flash[:notice] = "Request accepted successfully."
      redirect_to dashboard_marriage_profile_path(current_active_profile,
                                                  butterfly: "animate")
    else
      flash[:danger] = "You don't have enough butterflies or they are in use!"
      redirect_to new_order_path
    end
  end

  def reject_request
    cancel_request = current_active_profile.decline_request(@marriage_profile)
    if cancel_request.present?
      @marriage_profile.unblock_blocked_butterflies
      @marriage_profile.user.notifications.create(
        content: "#{current_active_profile.unique_id} did not accept your butterfly!",
        notifiable: @marriage_profile,
        will_email: false,
        will_sms: false
      )
      KobulOneMailer.with(user: @marriage_profile.user, profile: current_active_profile).get_rejection.deliver_later
      SmsService.call(
        @marriage_profile.user.phone_number.to_s,
        "A butterfly was not accepted. Find more profiles at www.bolokobul.com"
      )
    end
    flash[:notice] = "kobul (1) request cancelled"
    redirect_to dashboard_marriage_profile_path(current_active_profile)
  end

  def cancel_request
    cancel_request = current_active_profile.decline_request(@marriage_profile)
    if cancel_request.present?
      current_active_profile.unblock_blocked_butterflies
    end
    flash[:notice] = "kobul (1) request cancelled, you got your butterfly back!"
    redirect_to dashboard_marriage_profile_path(current_active_profile,
                                                butterfly: "bk_animate")
  end

  def remove_profile
    current_active_profile.remove_friend(@marriage_profile)
  end

  def block_profile
    current_active_profile.block_friend(@marriage_profile)
    flash[:notice] = "Blocked successfully."
    redirect_to dashboard_marriage_profile_path(current_active_profile)
  end

  def unblock_profile
    current_active_profile.unblock_friend(@marriage_profile)
    redirect_back fallback_location: root_path, notice: 'Unblocked successfully from your blocked list.'
  end

  def requested_profiles
    requested_profiles = current_active_profile.requested_friends
  end

  def pending_profiles
    @pending_profiles = current_active_profile.pending_friends
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
