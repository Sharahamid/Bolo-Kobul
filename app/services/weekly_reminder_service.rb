# Every other Friday, members who have not visited the site or app for 14 days get one
# "new matches for you" email and, on devices where notifications are on, one push
# notification.
# - no profile yet: create one
# - matches found: up to 5 matches, plus a nudge to reach 80% if the profile is below it
#   (Kobuls can only be sent from 80%)
# - no matches and profile under 80%: finish the profile
# Members can turn the email off with the unsubscribe link in it.
class WeeklyReminderService
  include LocaleHelper

  HOST = 'www.bolokobul.com'.freeze
  MATCHES_PER_EMAIL = 5
  INACTIVE_FOR = 14.days
  # Mailgun allows our account 100 emails an hour, shared with sign-up codes and other
  # emails. One reminder a minute (60 an hour) leaves room for those.
  EMAIL_GAP = 60.seconds
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
  def self.call(logger: Rails.logger, email_gap: EMAIL_GAP)
    sent = 0
    emailed = false
    recipients.find_each do |user|
      email = user.weekly_matches_email && user.email.present?
      push = WebPushService.configured? && user.push_subscriptions.exists?
      next unless email || push

      reminder = new(user).reminder
      next unless reminder

      if email
        sleep(email_gap) if emailed
        ReminderMailer.with(user: user, reminder: reminder).weekly.deliver_now
        emailed = true
      end
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

  # Written in the member's chosen language (English unless they picked Bangla)
  def reminder
    language = I18n.available_locales.map(&:to_s).include?(@user.locale.to_s) ? @user.locale : I18n.default_locale
    I18n.with_locale(language) { build_reminder }
  end

  private

  def t(key, **options)
    I18n.t(key, **options)
  end

  def build_reminder
    profile = @user.marriage_profiles.order(:id).first
    return no_profile unless profile

    matches = profile.partner_preference ? RecommendationService.daily_recommendations(profile).to_a.first(MATCHES_PER_EMAIL) : []
    return matches_found(profile, matches) if matches.any?
    return incomplete_profile(profile) unless profile.ready_for_kobul?

    nil
  end

  def urls
    Rails.application.routes.url_helpers
  end

  def no_profile
    link = urls.new_marriage_profile_url(host: HOST, protocol: 'https')
    {
      kind: :no_profile,
      subject: t('reminder.no_profile.subject'),
      title: t('reminder.no_profile.title'),
      lines: [t('reminder.no_profile.line1'), t('reminder.no_profile.line2')],
      button: t('reminder.no_profile.button'), link: link,
      push: push_payload(t('reminder.no_profile.push'), link)
    }
  end

  def incomplete_profile(profile)
    percent = local_digits(profile.profile_completeness.to_i)
    minimum = local_digits(MarriageProfile::KOBUL_MIN_COMPLETENESS)
    link = urls.profile_info_marriage_profile_url(profile, host: HOST, protocol: 'https')
    {
      kind: :incomplete,
      subject: t('reminder.incomplete.subject', percent: percent),
      title: t('reminder.incomplete.title', percent: percent),
      lines: [t('reminder.incomplete.line1', minimum: minimum), t('reminder.incomplete.line2')],
      button: t('reminder.incomplete.button'), link: link,
      push: push_payload(t('reminder.incomplete.push', percent: percent), link)
    }
  end

  def matches_found(profile, matches)
    count = matches.size
    shown = local_digits(count)
    link = urls.dashboard_marriage_profile_url(profile, host: HOST, protocol: 'https')
    percent = local_digits(profile.profile_completeness.to_i)
    {
      kind: :matches,
      subject: t('reminder.matches.subject', count: count, shown: shown),
      title: t('reminder.matches.title', count: count, shown: shown),
      lines: [t('reminder.matches.line1')],
      matches: matches.map { |m| m.calculate_matching_percentage!(profile); match_card(m) },
      complete_nudge: (profile.ready_for_kobul? ? nil : {
        text: t('reminder.matches.nudge', percent: percent, minimum: local_digits(MarriageProfile::KOBUL_MIN_COMPLETENESS)),
        link: urls.profile_info_marriage_profile_url(profile, host: HOST, protocol: 'https')
      }),
      button: t('reminder.matches.button'), link: link,
      push: push_payload(t('reminder.matches.push', count: count, shown: shown), link)
    }
  end

  def match_card(match)
    photo = match.profile_image.present? ? match.profile_image.url(:large_profile_thumb) : nil
    photo = "https://#{HOST}#{photo}" if photo&.start_with?('/')
    details = [(years_label(match.age) if match.age.present?),
               ("#{local_digits(match.height_ft)}'#{local_digits(match.height_inch)}\"" if match.height_ft.present?),
               (district_label(match.hometown) if match.hometown.present?),
               (enum_label(:marriage_profile, :highest_education_level, match.highest_education_level) if match.highest_education_level.present?)].compact
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
