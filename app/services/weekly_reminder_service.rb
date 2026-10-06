# Every other Friday, members who have not visited the site or app for 14 days get one
# "new matches for you" email and, on devices where notifications are on, one push
# notification.
# - no profile yet: create one
# - matches found: up to 5 matches, plus a nudge to reach 80% if the profile is below it
#   (Kobuls can only be sent from 80%)
# - no matches and profile under 80%: finish the profile
# Members can turn the email off with the unsubscribe link in it.
class WeeklyReminderService
  HOST = 'www.bolokobul.com'.freeze
  MATCHES_PER_EMAIL = 5
  INACTIVE_FOR = 14.days
  # Sent on alternate Fridays, counted from this one
  FIRST_FRIDAY = Date.new(2026, 10, 9)

  def self.sending_week?(date = Date.current)
    ((date - FIRST_FRIDAY).to_i / 7).even?
  end

  # Members whose last visit (or, before visits were recorded, last sign-in) is 14 days ago or more
  def self.recipients
    cutoff = INACTIVE_FOR.ago
    User.where(verified: true, deactivated: [false, nil])
        .where('last_seen_at < :cutoff OR (last_seen_at IS NULL AND (last_sign_in_at IS NULL OR last_sign_in_at < :cutoff))', cutoff: cutoff)
  end

  # Returns how many members were sent the email or the push notification
  def self.call(logger: Rails.logger)
    sent = 0
    recipients.find_each do |user|
      email = user.weekly_matches_email && user.email.present?
      push = WebPushService.configured? && user.push_subscriptions.exists?
      next unless email || push

      reminder = new(user).reminder
      next unless reminder

      ReminderMailer.with(user: user, reminder: reminder).weekly.deliver_now if email
      WebPushJob.perform_later(user.id, reminder[:push]) if push
      sent += 1
    rescue StandardError => e
      logger.warn("[WeeklyReminder] user #{user.id}: #{e.class}: #{e.message}")
    end
    sent
  end

  # Signed link that turns the weekly email off without logging in
  def self.unsubscribe_token(user)
    Rails.application.message_verifier(:weekly_matches_email).generate(user.id, purpose: :unsubscribe)
  end

  def self.user_from_token(token)
    id = Rails.application.message_verifier(:weekly_matches_email).verified(token.to_s, purpose: :unsubscribe)
    id && User.find_by(id: id)
  end

  def initialize(user)
    @user = user
  end

  def reminder
    profile = @user.marriage_profiles.order(:id).first
    return no_profile unless profile

    matches = profile.partner_preference ? RecommendationService.daily_recommendations(profile).to_a.first(MATCHES_PER_EMAIL) : []
    return matches_found(profile, matches) if matches.any?
    return incomplete_profile(profile) unless profile.ready_for_kobul?

    nil
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
      button: 'Create My Profile', link: link,
      push: push_payload('Create your profile so we can find your matches.', link)
    }
  end

  def incomplete_profile(profile)
    percent = profile.profile_completeness.to_i
    link = urls.profile_info_marriage_profile_url(profile, host: HOST, protocol: 'https')
    {
      kind: :incomplete,
      subject: "✨ Your profile is #{percent}% complete. Finish it to get noticed",
      title: "Your profile is #{percent}% complete",
      lines: ["Complete profiles get up to 5x more attention, and you can send Kobuls once your profile is at least #{MarriageProfile::KOBUL_MIN_COMPLETENESS}% complete.",
              'Add your photos, family, education and occupation. It only takes a few minutes.'],
      button: 'Complete My Profile', link: link,
      push: push_payload("Your profile is #{percent}% complete. Finish it to start sending Kobuls.", link)
    }
  end

  def matches_found(profile, matches)
    count = matches.size
    noun = count == 1 ? 'match' : 'matches'
    link = urls.dashboard_marriage_profile_url(profile, host: HOST, protocol: 'https')
    percent = profile.profile_completeness.to_i
    {
      kind: :matches,
      subject: "🦋 #{count} new #{noun} picked for you",
      title: "#{count} new #{noun} picked for you",
      lines: ['We have picked these profiles from your preferences. Send a Kobul to someone you like. Your next chapter could start today!'],
      matches: matches.map { |m| m.calculate_matching_percentage!(profile); match_card(m) },
      complete_nudge: (profile.ready_for_kobul? ? nil : {
        text: "Your profile is #{percent}% complete. Reach #{MarriageProfile::KOBUL_MIN_COMPLETENESS}% to send Kobuls.",
        link: urls.profile_info_marriage_profile_url(profile, host: HOST, protocol: 'https')
      }),
      button: 'See All My Matches', link: link,
      push: push_payload("#{count} new #{noun} picked for you. Tap to see them.", link)
    }
  end

  def match_card(match)
    photo = match.profile_image.present? ? match.profile_image.url(:large_profile_thumb) : nil
    photo = "https://#{HOST}#{photo}" if photo&.start_with?('/')
    details = [("#{match.age} years" if match.age.present?),
               ("#{match.height_ft}'#{match.height_inch}\"" if match.height_ft.present?),
               match.hometown&.humanize,
               match.highest_education_level&.humanize].compact
    {
      id: match.unique_id,
      verified: match.verified,
      percent: match.matching_percentage.to_i,
      details: details.join(' · '),
      photo: photo,
      link: urls.profile_info_marriage_profile_url(match, host: HOST, protocol: 'https')
    }
  end

  def push_payload(body, link)
    { 'title' => 'Bolo Kobul', 'body' => body, 'url' => link.sub(%r{\Ahttps://[^/]+}, ''), 'tag' => 'weekly-matches' }
  end
end
