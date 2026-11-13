# A member's report about another profile (fake profile, abusive messages, scam ...).
# Reports go to support@bolokobul.com and are reviewed in the admin panel.
class ProfileReport < ApplicationRecord
  REASONS = {
    'fake_profile'      => 'Fake profile or false information',
    'inappropriate'     => 'Inappropriate photos or content',
    'underage'          => 'Under 18 or child safety concern',
    'harassment'        => 'Harassment or abusive messages',
    'money'             => 'Asking for money or a scam',
    'already_married'   => 'Already married or not serious',
    'other'             => 'Something else'
  }.freeze
  STATUSES = %w[open reviewing action_taken dismissed].freeze

  belongs_to :reporter_profile, class_name: 'MarriageProfile', optional: true
  belongs_to :reported_profile, class_name: 'MarriageProfile'

  validates :reason, inclusion: { in: REASONS.keys }
  validates :status, inclusion: { in: STATUSES }
  validates :details, length: { maximum: 1000 }
  validates :details, presence: { message: 'please tell us a little about what happened' }, if: -> { reason == 'other' }

  scope :unresolved, -> { where(status: %w[open reviewing]) }

  # Backup for the controller check: no second open report from the same member on the same profile
  validate :no_open_duplicate, on: :create

  def no_open_duplicate
    return unless reporter_profile_id && reported_profile_id

    if ProfileReport.unresolved.exists?(reporter_profile_id: reporter_profile_id, reported_profile_id: reported_profile_id)
      errors.add(:base, 'you have already reported this profile')
    end
  end

  def reason_label
    REASONS[reason] || reason.to_s.humanize
  end

  # How many different members have reported this profile
  def reporter_count
    ProfileReport.where(reported_profile_id: reported_profile_id).distinct.count(:reporter_profile_id)
  end
end
