# Daily friendly nudges (bell + phone alert only, never SMS or email), at most one per
# member per day, only for members who left them on (users.nudges_enabled).
#   1. Someone saved you to their favourites (last 24 hours)
#   2. A new member who is a strong match (85%+) joined in the last 2 days
#   3. On Fridays: how many new members this week match your preferences (70%+)
namespace :nudges do
  desc 'Send one friendly nudge to each member who has something new'
  task daily: :environment do
    sent = 0
    link_style = "style='color:#FFB627;font-weight:600;'"
    User.where(nudges_enabled: true, verified: true, deactivated: false, deletion_requested_at: nil)
        .where('last_sign_in_at > ?', 60.days.ago)
        .where('last_nudge_at IS NULL OR last_nudge_at < ?', 20.hours.ago)
        .find_each do |user|
      profile = user.main_marriage_profile
      next unless profile&.persisted? && profile.partner_preference

      hidden = (profile.friend_ids + profile.pending_friend_ids + profile.requested_friend_ids +
                profile.blocked_friend_ids + ProfilePass.hidden_ids_for(profile) + [profile.id]).uniq
      content = nil

      # 1. Saved you
      saved = Favourite.where(favourite_profile_id: profile.id).where('created_at > ?', 24.hours.ago)
                       .where.not(marriage_profile_id: hidden).count
      if saved.positive?
        content = if saved == 1
                    "Someone saved you to their favourites today 💛 <a href='/bk-plus/saved-you' #{link_style}>See who</a>"
                  else
                    "#{saved} members saved you to their favourites today 💛 <a href='/bk-plus/saved-you' #{link_style}>See who</a>"
                  end
      end

      new_members = lambda do |since, min_pct|
        MarriageProfile.where.not(gender: profile.gender).where.not(id: hidden)
                       .where('marriage_profiles.created_at > ?', since)
                       .includes(:user, :partner_preference, :occupations, :cultural_value)
                       .reject { |p| p.user.nil? || p.user.deactivated }
                       .each { |p| p.calculate_matching_percentage!(profile) }
                       .select { |p| p.matching_percentage.to_i >= min_pct }
      end

      # 2. A strong new match
      if content.nil?
        best = new_members.call(2.days.ago, 85).max_by(&:matching_percentage)
        if best
          content = "A #{best.matching_percentage}% match just joined Bolo Kobul ✨ <a href='/marriage_profiles/#{best.slug}/profile_info' #{link_style}>Take a look</a>"
        end
      end

      # 3. Fridays: this week's new matches
      if content.nil? && Time.current.in_time_zone('Asia/Dhaka').friday?
        count = new_members.call(7.days.ago, 70).size
        if count.positive?
          content = "#{count} new #{count == 1 ? 'member matches' : 'members match'} your preferences this week 💛 <a href='/marriage_profiles/#{profile.slug}/dashboard' #{link_style}>See them</a>"
        end
      end

      next unless content

      user.notifications.create(content: content, notifiable: profile, will_email: false, will_sms: false)
      user.update_column(:last_nudge_at, Time.current)
      sent += 1
    rescue StandardError => e
      Rails.logger.error("[nudges] user #{user.id}: #{e.class}: #{e.message}")
    end
    puts "Friendly nudges sent: #{sent}"
  end
end
