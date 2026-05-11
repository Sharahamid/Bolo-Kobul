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
        content: "Your Kobul 1 request expired without a response. Keep exploring — your soulmate is waiting!",
        notifiable: marriage_profile,
        will_email: false,
        will_sms: false
      )
      KobulOneMailer.with(sender_profile: marriage_profile, friend: friendship.friend).request_expired.deliver_now
      SmsService.call(
        marriage_profile.user.phone_number.to_s,
        "Your Kobul 1 request has expired without a response. Keep going — your perfect match is out there! Visit bolokobul.com"
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
        content: "Your Kobul 2 request expired without a response. Don't give up — keep exploring profiles!",
        notifiable: marriage_profile,
        will_email: false,
        will_sms: false
      )
      KobulTwoMailer.with(sender_profile: marriage_profile, friend: chat_friendship.chat_friend).request_expired.deliver_now
      SmsService.call(
        marriage_profile.user.phone_number.to_s,
        "Your Kobul 2 request has expired without a response. Keep exploring — your perfect match is waiting! Visit bolokobul.com"
      )
      puts "MarriageProfile-#{chat_friendship.marriage_profile_id} Kobul-2 request expired for MarriageProfile-#{chat_friendship.chat_friend_id}"
      marriage_profile.decline_chat_request(chat_friendship.chat_friend)
    end
  end

  desc "Clean up old notifications"
  task clean_notifications: :environment do
    deleted = Notification.where('is_read = true AND created_at < ?', 1.month.ago).delete_all
    deleted += Notification.where('is_read = false AND created_at < ?', 3.months.ago).delete_all
    puts "Deleted #{deleted} old notifications"
  end

  desc "Remind users with incomplete profiles"
  task profile_incomplete_reminder: :environment do
    MarriageProfile.all.each do |profile|
      progress = profile.progress.to_i
      next if progress >= 80
      next if profile.user.nil?
      profile.user.notifications.create(
        content: "Your profile is #{progress}% complete. A complete profile gets 5x more attention! <a href='/marriage_profiles/#{profile.slug}/edit' style='color:#FFB627;font-weight:600;'>Complete Profile</a>",
        notifiable: profile,
        will_email: false,
        will_sms: false
      )
    end
    puts "Profile reminders sent"
  end

  desc "Send weekly profile view summary to each user"
  task weekly_profile_view_summary: :environment do
    MarriageProfile.all.each do |profile|
      next if profile.user.nil?
      key = "profile_views_#{profile.id}"
      view_count = Rails.cache.read(key) || 0
      Rails.cache.delete(key)
      next if view_count == 0
      profile.user.notifications.create(
        content: "Your profile was viewed #{view_count} #{view_count == 1 ? 'time' : 'times'} this week! A complete profile attracts more attention. <a href='/marriage_profiles/#{profile.slug}/edit' style='color:#FFB627;font-weight:600;'>Complete Profile</a>",
        notifiable: profile,
        will_email: false,
        will_sms: false
      )
    end
    puts "Weekly profile view summaries"
  end
end
