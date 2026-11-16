# Short addresses used in SMS, so a text fits in one SMS part:
#   bolokobul.com/p/BK0000262  -> that member's profile
#   bolokobul.com/c/BK0000262  -> the chat with that member
# Members who are not logged in log in first and then land on the page.
class ShortLinksController < ApplicationController
  before_action :authenticate_user!
  before_action :find_profile

  def profile
    redirect_to profile_info_marriage_profile_path(@target)
  end

  def chat
    redirect_to profile_message_path(@target)
  end

  private

  def find_profile
    code = params[:id].to_s
    @target = MarriageProfile.find_by(slug: code.downcase) ||
              (code =~ /\A(?:bk)?0*(\d+)\z/i && MarriageProfile.find_by(id: Regexp.last_match(1).to_i))
    redirect_to user_homepage(current_user) unless @target
  end
end
