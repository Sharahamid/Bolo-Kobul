module ChatFriendshipsHelper
  def get_pending_chat_profiles
    ChatFriendship.where(chat_friend_id: current_active_profile.id, status: 1).map(&:marriage_profile)
  end
end
