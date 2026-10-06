# "Report & Block": a member reports another profile to the Bolo Kobul team and,
# by default, blocks it at the same time
class ProfileReportsController < ApplicationController
  before_action :authenticate_user!
  before_action :check_current_active_profile
  # Counted per member: many mobile users in Bangladesh share one internet address
  rate_limit to: 10, within: 1.hour, only: :create, by: -> { current_user.id },
             with: -> { redirect_back fallback_location: root_path, warning: 'Too many reports in a short time. Please try again later.' }

  def create
    reported = MarriageProfile.friendly.find(params[:profile_id])
    if current_user.marriage_profiles.exists?(reported.id)
      return redirect_back(fallback_location: root_path, warning: "You can't report your own profile.")
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
      flash[:notice] = "Thank you. We've received your report and blocked #{reported.unique_id}. Our team will review it within 24 hours."
      redirect_to user_homepage(current_user)
    else
      flash[:notice] = "Thank you. We've received your report about #{reported.unique_id}. Our team will review it within 24 hours."
      redirect_back fallback_location: user_homepage(current_user)
    end
  end
end
