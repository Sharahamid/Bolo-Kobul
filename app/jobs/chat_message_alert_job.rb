# Email telling a member they have a new chat message (never the message itself)
class ChatMessageAlertJob < ApplicationJob
  queue_as :default

  def perform(user_id, sender_profile_id, chat_url)
    user = User.find_by(id: user_id)
    sender_profile = MarriageProfile.find_by(id: sender_profile_id)
    return if user.nil? || sender_profile.nil? || user.deactivated || user.email.blank?

    ChatMessageMailer.with(user: user, sender_profile: sender_profile, chat_url: chat_url).new_message.deliver_now
  end
end
