namespace :butterfly do
  desc '1st Kobuls expire after the days set in admin (Butterfly prices; 7 by default); the butterflies are returned'
  task :return_after_7_days => :environment do
    #
    # Check Kobul-1 expirations
    #
    expired_friendships = HasFriendship::Friendship.pending.where('created_at <= ?', ButterflyConfig.kobul1_expiry_days.days.ago)
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
        "Your 1st Kobul expired without a response. Keep going - your perfect match is out there! bolokobul.com",
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
    # It expires at the first nightly run after it is N days old (N set in admin).
    days = ButterflyConfig.kobul1_expiry_days
    before = ButterflyConfig::REMINDER_DAYS_BEFORE
    if days <= before
      puts "1st Kobuls expire after #{days} day(s): too short for a #{before}-day reminder, none sent"
      next
    end
    helpers = Rails.application.routes.url_helpers
    sent = 0
    HasFriendship::Friendship.pending.where(created_at: (days - before + 1).days.ago..(days - before).days.ago).find_each do |friendship|
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

  # Runs once a day. Each Kobul falls in the 24-hour window "3 to 4 days ago" exactly once,
  # so every member gets at most one reminder per Kobul.
  KOBUL_NUDGE_DAYS = 3

  desc '2nd Kobul with no answer after 3 days: one reminder to the receiver'
  task kobul2_reminders: :environment do
    helpers = Rails.application.routes.url_helpers
    window = (KOBUL_NUDGE_DAYS + 1).days.ago..KOBUL_NUDGE_DAYS.days.ago
    hidden = User.deactivated_users_profile_ids
    sent = 0
    # The receiver's row of a 2nd Kobul has status "requested"
    ChatFriendship.requested.where(created_at: window).find_each do |row|
      receiver = row.marriage_profile
      sender = row.chat_friend
      user = receiver&.user
      next if sender.nil? || user.nil? || user.deactivated || hidden.include?(sender.id)

      begin
        user.notifications.create(
          content: "Reminder: #{sender.unique_id} sent you a 2nd Kobul #{KOBUL_NUDGE_DAYS} days ago and is waiting for your answer. <a href='#{helpers.profile_info_marriage_profile_path(sender)}' style='color:#FFB627;font-weight:600;'>See Profile</a>",
          notifiable: receiver,
          will_email: false,
          will_sms: false
        )
        KobulTwoMailer.with(user: user, profile: sender, receiver_profile: receiver).reminder.deliver_later if user.email.present?
        sent += 1
      rescue StandardError => e
        Rails.logger.error "[kobul2 reminder] #{row.id}: #{e.message}"
      end
    end
    puts "2nd Kobul reminders sent: #{sent}"
  end

  desc '1st Kobul accepted 3 days ago and no 2nd Kobul yet: one nudge to each of the two members'
  task kobul2_nudges: :environment do
    helpers = Rails.application.routes.url_helpers
    window = (KOBUL_NUDGE_DAYS + 1).days.ago..KOBUL_NUDGE_DAYS.days.ago
    hidden = User.deactivated_users_profile_ids
    sent = 0
    # An accepted 1st Kobul has two rows (one for each member), so each member is nudged once
    HasFriendship::Friendship.accepted.where(friendable_type: 'MarriageProfile', blocker_id: nil, updated_at: window).find_each do |row|
      own = MarriageProfile.find_by(id: row.friendable_id)
      other = MarriageProfile.find_by(id: row.friend_id)
      user = own&.user
      next if other.nil? || user.nil? || user.deactivated || hidden.include?(other.id)
      # Either of them has already sent a 2nd Kobul (or they are chatting)
      next if ChatFriendship.where(marriage_profile_id: own.id, chat_friend_id: other.id).exists?

      begin
        user.notifications.create(
          content: "You and #{other.unique_id} accepted a 1st Kobul #{KOBUL_NUDGE_DAYS} days ago. Send a 2nd Kobul to start chatting. <a href='#{helpers.profile_info_marriage_profile_path(other)}' style='color:#FFB627;font-weight:600;'>View Profile</a>",
          notifiable: own,
          will_email: false,
          will_sms: false
        )
        KobulTwoMailer.with(user: user, profile: other, own_profile: own).nudge.deliver_later if user.email.present?
        sent += 1
      rescue StandardError => e
        Rails.logger.error "[kobul2 nudge] #{row.id}: #{e.message}"
      end
    end
    puts "2nd Kobul nudges sent: #{sent}"
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
