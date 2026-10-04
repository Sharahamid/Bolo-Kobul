class ChatMessageMailer < ApplicationMailer
  # Someone sent the user a chat message
  def new_message
    @receiver = params[:user]
    @sender_profile = params[:sender_profile]
    @chat_url = params[:chat_url]
    mail(to: @receiver.email,
         subject: "💬 New message from #{@sender_profile.unique_id}")
  end
end
