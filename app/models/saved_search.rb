# A search a member saved from the search page (age, religion, hometown and, with
# advanced search, height, education and so on). Stored as the same filters the
# search page uses, so running it is just opening the search with them.
class SavedSearch < ApplicationRecord
  MAX_PER_PROFILE = 5
  KEYS = %w[age_from age_to religion hometown hometown_country hometown_city].freeze
  LIST_KEYS = %w[height marital_status blood_group highest_education_level occupation].freeze

  belongs_to :marriage_profile

  validates :name, presence: true, length: { maximum: 60 }
  validate :within_limit, on: :create
  validate :has_filters

  # Only the known search filters, without blanks
  def self.criteria_from(params)
    plain = KEYS.to_h { |key| [key, params[key].to_s.strip] }.reject { |_, value| value.blank? }
    lists = LIST_KEYS.to_h { |key| [key, Array(params[key]).map(&:to_s).reject(&:blank?)] }.reject { |_, value| value.empty? }
    plain.merge(lists)
  end

  # How many profiles match now (and how many of them joined since the last run)
  def matches(created_after: nil)
    SearchService.with_params(ActionController::Parameters.new(criteria.merge('created_after' => created_after)),
                              marriage_profile_id)
  end

  def new_matches_count
    return 0 unless last_run_at

    matches(created_after: last_run_at).total_entries
  end

  private

  def within_limit
    return unless marriage_profile && marriage_profile.saved_searches.count >= MAX_PER_PROFILE

    errors.add(:base, :too_many, message: I18n.t('saved_search.limit', count: MAX_PER_PROFILE))
  end

  def has_filters
    errors.add(:criteria, :blank) if criteria.blank?
  end
end
