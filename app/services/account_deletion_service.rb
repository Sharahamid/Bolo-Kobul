# Permanently erases a member's account, 30 days after they asked for it (Google Play
# requires that members can delete their account and data).
#
# Erased: the account, its marriage profiles with their details and photos, chats
# (whole conversations), Kobul requests, favourites, notifications and phone
# notification subscriptions - including other members' links to these profiles.
# Kept for accounting, without the member's name, phone or email: orders and payments.
class AccountDeletionService
  def self.call(user)
    new(user).call
  end

  def initialize(user)
    @user = user
  end

  def call
    profile_ids = @user.marriage_profiles.pluck(:id)

    ActiveRecord::Base.transaction do
      # Conversations with other members (their messages too: a chat needs two people)
      ChatRoom.where(id: ChatRoomUser.where(marriage_profile_id: profile_ids).select(:chat_room_id)).destroy_all

      # Other members' Kobuls, favourites and requests that point at these profiles
      Friendship.where(friend_id: profile_ids).or(Friendship.where(friendable_id: profile_ids)).delete_all
      ChatFriendship.where(chat_friend_id: profile_ids).delete_all
      Favourite.where(favourite_profile_id: profile_ids).delete_all
      PartnerRequest.where(sender_id: profile_ids).or(PartnerRequest.where(recipient_id: profile_ids))
                    .or(PartnerRequest.where(blocker_id: profile_ids)).delete_all

      # Payment records stay for the accounts, but no longer identify the member
      orders = Order.where(user_id: @user.id)
      Transaction.where(order_id: orders.select(:id)).update_all(transaction_by: nil)
      orders.update_all(user_id: nil, customer_name: 'Deleted member', customer_phone: nil, customer_email: nil)

      # The account itself; its profiles, profile details, photos, documents,
      # notifications, support tickets and push subscriptions go with it
      @user.destroy!
    end
  end
end
