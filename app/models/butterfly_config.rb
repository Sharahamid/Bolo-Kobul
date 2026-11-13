# == Schema Information
#
# Table name: butterfly_configs
#
#  id                       :bigint           not null, primary key
#  adv_search_butterflies   :integer          default(0)
#  butterfly_animation      :boolean          default(FALSE)
#  butterfly_price          :float            default(0.0)
#  chat_butterflies         :integer          default(0)
#  max_marriage_profiles    :integer          default(5)
#  num_of_free_butterfly    :integer          default(0)
#  profile_view_butterflies :integer          default(0)
#  text_alert_butterflies   :integer          default(0)
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#

class ButterflyConfig < ApplicationRecord
  DEFAULT_KOBUL1_EXPIRY_DAYS = 7
  # The receiver is reminded this many days before an unanswered 1st Kobul expires
  REMINDER_DAYS_BEFORE = 2

  validates :kobul1_expiry_days, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 90 },
                                 if: -> { has_attribute?(:kobul1_expiry_days) }

  # Days an unanswered 1st Kobul stays open before it expires and the butterflies go back.
  # Falls back to 7 if the setting is missing, so expiry never stops working.
  def self.kobul1_expiry_days
    days = last&.try(:kobul1_expiry_days).to_i
    days.positive? ? days : DEFAULT_KOBUL1_EXPIRY_DAYS
  rescue StandardError
    DEFAULT_KOBUL1_EXPIRY_DAYS
  end
end
