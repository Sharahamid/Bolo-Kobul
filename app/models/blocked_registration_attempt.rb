# A sign-up stopped by a bot check (or never finished), kept for the registration report
# so the team can spot a real person who was turned away
class BlockedRegistrationAttempt < ApplicationRecord
  # attempt_type => [what happened, could this be a real person?]
  REASONS = {
    'honeypot'       => ['Filled in the hidden bot trap', false],
    'name_filter'    => ['All-capital name', false],
    'name_check'     => ['Random-letter name refused', false],
    'too_fast'       => ['Form sent within 3 seconds (asked to press Register again)', true],
    'phone_check'    => ['Phone number refused (no country code, or not a valid Bangladeshi mobile)', true],
    'rate_limit'     => ['Too many sign-ups from one connection within an hour', true],
    'never_verified' => ['Signed up but never entered the code (removed after 7 days)', true]
  }.freeze

  def self.record(type, name:, email:, phone:, ip: nil)
    create(attempt_type: type, name: name.to_s.first(100), email: email.to_s.first(150), phone: phone.to_s.first(30), ip_address: ip)
  rescue StandardError => e
    Rails.logger.warn("[blocked sign-up] could not record #{type}: #{e.message}")
  end

  def reason
    REASONS.dig(attempt_type, 0) || attempt_type.to_s.humanize
  end

  def maybe_real_person?
    REASONS.dig(attempt_type, 1) || false
  end
end
