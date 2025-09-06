namespace :butterfly do
  desc 'Butterfly return to requester after 7 days if not accepted or rejected'
  task :return_after_7_days => :environment do
    #
    # Check Kobul-1 expirations
    #
    expired_friendships = HasFriendship::Friendship.pending.where('created_at <= ?', 7.days.ago)
    expired_friendships.each do |friendship|
      marriage_profile = friendship.friendable
      marriage_profile.unblock_blocked_butterflies
      marriage_profile.user.notifications.create(
        content: "Your butterfly has returned and wasn't accepted in time",
        notifiable: marriage_profile,
        will_email: false,
        will_sms: false
      )
      KobulOneMailer.with(sender_profile: marriage_profile, friend: friendship.friend).request_expired.deliver_now
      SmsService.call(
        marriage_profile.user.phone_number.to_s,
        "A butterfly has returned. Use it to look out for more profiles. Visit bolokobul.com"
      )
      puts "MarriageProfile-#{friendship.friendable_id} Kobul-1 request expired for MarriageProfile-#{friendship.friend_id}"
      friendship.destroy
    end

    #
    # Check Kobul-2 expirations
    #
    expired_chat_friendships = ChatFriendship.pending.where('created_at <= ?', 7.days.ago)
    expired_chat_friendships.each do |chat_friendship|
      marriage_profile = chat_friendship.marriage_profile
      marriage_profile.unblock_blocked_butterflies_chat
      marriage_profile.user.notifications.create(
        content: "Kobul-2 request expired from your profile named #{marriage_profile.name}",
        notifiable: marriage_profile
      )
      puts "MarriageProfile-#{chat_friendship.marriage_profile_id} Kobul-2 request expired for MarriageProfile-#{chat_friendship.chat_friend_id}"
      marriage_profile.decline_chat_request(chat_friendship.chat_friend)
    end
  end
end
