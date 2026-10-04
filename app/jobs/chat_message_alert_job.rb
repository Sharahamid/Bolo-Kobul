# Email and SMS telling a member they have a new chat message (never the message itself)
class ChatMessageAlertJob < ApplicationJob
  queue_as :default

  def perform(user_id, sender_profile_id, chat_url)
    user = User.find_by(id: user_id)
    sender_profile = MarriageProfile.find_by(id: sender_profile_id)
    return if user.nil? || sender_profile.nil? || user.deactivated

    ChatMessageMailer.with(user: user, sender_profile: sender_profile, chat_url: chat_url).new_message.deliver_now
    SmsService.call(
      user.phone_number.to_s,
      "You have a new message from #{sender_profile.unique_id} on Bolo Kobul. Read and reply: #{chat_url}"
    )
  end
end
