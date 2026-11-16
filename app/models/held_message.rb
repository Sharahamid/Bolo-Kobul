# A phone notification or text that came up during quiet hours and waits for the morning.
# See QuietHours.
class HeldMessage < ApplicationRecord
  CHANNELS = %w[push sms].freeze
  validates :channel, inclusion: { in: CHANNELS }
end
