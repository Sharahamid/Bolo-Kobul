# A reaction on a chat message (WhatsApp style): each member can leave one emoji on a
# message; choosing the same emoji again takes it off, another emoji replaces it.
class MessageReaction < ApplicationRecord
  EMOJIS = %w[👍 ❤️ 😂 😮 😢 🙏].freeze

  belongs_to :message
  belongs_to :marriage_profile

  validates :emoji, inclusion: { in: EMOJIS }
  validates :marriage_profile_id, uniqueness: { scope: :message_id }

  # The reactions on one message, for the chat page: [{ 'profile_id' => 12, 'emoji' => '👍' }, ...]
  def self.list_for(message)
    message.reactions.sort_by(&:created_at).map { |r| { 'profile_id' => r.marriage_profile_id, 'emoji' => r.emoji } }
  end
end
