namespace :butterfly do
  desc '1st Kobuls expire after 7 days without an answer; the butterflies are returned'
  task :return_after_7_days => :environment do
    #
    # Check Kobul-1 expirations
    #
    expired_friendships = HasFriendship::Friendship.pending.where('created_at <= ?', 7.days.ago)
    expired_friendships.each do |friendship|
      marriage_profile = friendship.friendable
      marriage_profile.unblock_blocked_butterflies
      marriage_profile.user.notifications.create(
        content: "Your 1st Kobul expired without a response. Keep exploring — your soulmate is waiting!",
        notifiable: marriage_profile,
        will_email: false,
        will_sms: false
      )
      KobulOneMailer.with(sender_profile: marriage_profile, friend: friendship.friend).request_expired.deliver_later
      SmsService.call(
        marriage_profile.user.phone_number.to_s,
        "Your 1st Kobul has expired without a response. Keep going — your perfect match is out there! Visit bolokobul.com",
        kind: :kobul1_expired
      )
      puts "MarriageProfile-#{friendship.friendable_id} Kobul-1 request expired for MarriageProfile-#{friendship.friend_id}"
      friendship.destroy
    end
    # 2nd Kobuls do not expire: they stay pending until the sender cancels or the
    # other member rejects them.
  end

  desc 'Reminder to the receiver 2 days before an unanswered 1st Kobul expires'
  task expiry_reminders: :environment do
    # Runs once a day; each 1st Kobul falls in this 24-hour window exactly once.
    # It expires at the first nightly run after it is 7 days old.
    helpers = Rails.application.routes.url_helpers
    sent = 0
    HasFriendship::Friendship.pending.where(created_at: 6.days.ago..5.days.ago).find_each do |friendship|
      sender = friendship.friendable
      receiver_user = friendship.friend&.user
      next if sender.nil? || receiver_user.nil? || receiver_user.deactivated

      begin
        # Web notification; the phone/app notification goes out with it automatically
        receiver_user.notifications.create(
          content: "Reminder: a 1st Kobul you received expires in 2 days. Accept or decline it before it closes. <a href='#{helpers.profile_info_marriage_profile_path(sender)}' style='color:#FFB627;font-weight:600;'>See Who</a>",
          notifiable: friendship.friend,
          will_email: false,
          will_sms: false
        )
        KobulOneMailer.with(user: receiver_user, profile: sender).expiry_reminder.deliver_later
        sent += 1
      rescue StandardError => e
        Rails.logger.error "[kobul reminder] #{friendship.id}: #{e.message}"
      end
    end
    puts "1st Kobul expiry reminders sent: #{sent}"
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
      progress = profile.profile_completeness.to_i
      next if progress >= 80
      next if profile.user.nil?
      profile.user.notifications.create(
        content: "Your profile is #{progress}% complete. A complete profile gets much more attention! <a href='/marriage_profiles/#{profile.slug}/profile_info' style='color:#FFB627;font-weight:600;'>Complete Profile</a>",
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
        content: "Your profile was viewed #{view_count} #{view_count == 1 ? 'time' : 'times'} this week! A complete profile attracts more attention. <a href='/marriage_profiles/#{profile.slug}/profile_info' style='color:#FFB627;font-weight:600;'>Complete Profile</a>",
        notifiable: profile,
        will_email: false,
        will_sms: false
      )
    end
    puts "Weekly profile view summaries"
  end
end
