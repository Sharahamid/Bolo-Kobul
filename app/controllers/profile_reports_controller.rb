# "Report & Block": a member reports another profile to the Bolo Kobul team and,
# by default, blocks it at the same time
class ProfileReportsController < ApplicationController
  before_action :authenticate_user!
  before_action :check_current_active_profile
  # Counted per member: many mobile users in Bangladesh share one internet address
  rate_limit to: 10, within: 1.hour, only: :create, by: -> { current_user.id },
             with: -> { redirect_back fallback_location: root_path, warning: I18n.t('report.flash.too_many') }

  def create
    reported = MarriageProfile.friendly.find(params[:profile_id])
    if current_user.marriage_profiles.exists?(reported.id)
      return redirect_back(fallback_location: root_path, warning: I18n.t('report.flash.own'))
    end

    # One open report per member per profile: a second tap (or a repeat report) is not saved
    # again while the team is still looking at the first one
    if ProfileReport.unresolved.exists?(reporter_profile_id: current_active_profile.id, reported_profile_id: reported.id)
      current_active_profile.block_profile!(reported) if params[:block] == '1'
      flash[:notice] = I18n.t('report.flash.already', id: reported.unique_id)
      return params[:block] == '1' ? redirect_to(user_homepage(current_user)) : redirect_back(fallback_location: user_homepage(current_user))
    end

    # At most MAX_OPEN_PER_MEMBER reports waiting for review per member (all their profiles)
    open_count = ProfileReport.unresolved.where(reporter_profile_id: current_user.marriage_profiles.select(:id)).count
    if open_count >= ProfileReport::MAX_OPEN_PER_MEMBER
      current_active_profile.block_profile!(reported) if params[:block] == '1'
      key = params[:block] == '1' ? 'report.flash.limit_blocked' : 'report.flash.limit'
      flash[:warning] = I18n.t(key, count: helpers.local_digits(ProfileReport::MAX_OPEN_PER_MEMBER), id: reported.unique_id)
      return params[:block] == '1' ? redirect_to(user_homepage(current_user)) : redirect_back(fallback_location: user_homepage(current_user))
    end

    report = ProfileReport.new(reporter_profile: current_active_profile, reported_profile: reported,
                               reason: params[:reason], details: params[:details].to_s.strip.presence)
    unless report.save
      return redirect_back(fallback_location: root_path, danger: "Report not sent: #{report.errors.full_messages.to_sentence}")
    end

    begin
      AdminSupportMailer.profile_reported(report).deliver_later
    rescue StandardError => e
      Rails.logger.warn("[Report] admin email failed: #{e.message}")
    end

    if params[:block] == '1'
      current_active_profile.block_profile!(reported)
      flash[:notice] = I18n.t('report.flash.blocked', id: reported.unique_id)
      redirect_to user_homepage(current_user)
    else
      flash[:notice] = I18n.t('report.flash.received', id: reported.unique_id)
      redirect_back fallback_location: user_homepage(current_user)
    end
  end
end
