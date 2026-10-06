# Friday reminder email to every active member who has not used the site or app for
# 7 days:
# - no profile yet: create one
# - profile under 80% complete: finish it
# - otherwise: look at today's recommended profiles
class WeeklyReminderService
  HOST = 'www.bolokobul.com'.freeze

  INACTIVE_FOR = 7.days

  # Members whose last visit (or, before visits were recorded, last sign-in) is a week ago or more
  def self.recipients
    cutoff = INACTIVE_FOR.ago
    User.where(verified: true, deactivated: [false, nil])
        .where.not(email: [nil, ''])
        .where('last_seen_at < :cutoff OR (last_seen_at IS NULL AND (last_sign_in_at IS NULL OR last_sign_in_at < :cutoff))', cutoff: cutoff)
  end

  def self.call(logger: Rails.logger)
    sent = 0
    recipients.find_each do |user|
      reminder = new(user).reminder
      next unless reminder

      ReminderMailer.with(user: user, reminder: reminder).weekly.deliver_now
      sent += 1
    rescue StandardError => e
      logger.warn("[WeeklyReminder] user #{user.id}: #{e.class}: #{e.message}")
    end
    sent
  end

  def initialize(user)
    @user = user
  end

  def reminder
    profile = @user.marriage_profiles.order(:id).first
    return no_profile unless profile

    incomplete = @user.marriage_profiles.where('profile_completeness < 80 OR profile_completeness IS NULL').order(:id).first
    incomplete ? incomplete_profile(incomplete) : recommendations(profile)
  end

  private

  def urls
    Rails.application.routes.url_helpers
  end

  def no_profile
    link = urls.new_marriage_profile_url(host: HOST, protocol: 'https')
    {
      kind: :no_profile,
      subject: '💛 Your life partner could be waiting on Bolo Kobul',
      title: 'Start your search today',
      lines: ['You have joined Bolo Kobul, but your marriage profile is not set up yet.',
              'Create your profile so we can recommend people who match what you are looking for.'],
      button: 'Create My Profile', link: link
    }
  end

  def incomplete_profile(profile)
    percent = profile.profile_completeness.to_i
    link = urls.edit_marriage_profile_url(profile, host: HOST, protocol: 'https')
    {
      kind: :incomplete,
      subject: "✨ Your profile is #{percent}% complete. Finish it to get noticed",
      title: "Your profile is #{percent}% complete",
      lines: ['Complete profiles get up to 5x more attention, and you can send Kobuls once your profile is at least 80% complete.',
              'Add your photos, family, education and preferences. It only takes a few minutes.'],
      button: 'Complete My Profile', link: link
    }
  end

  def recommendations(profile)
    link = urls.dashboard_marriage_profile_url(profile, host: HOST, protocol: 'https')
    {
      kind: :recommendations,
      subject: '🦋 New matches are waiting for you on Bolo Kobul',
      title: 'See who matches you this week',
      lines: ['We have picked profiles that match your preferences.',
              'Take a look and send a Kobul to someone you like. Your next chapter could start today!'],
      button: 'See My Matches', link: link
    }
  end
end
