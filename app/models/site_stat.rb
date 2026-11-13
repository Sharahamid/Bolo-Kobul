# One row of homepage numbers, changed in Admin > Settings > Homepage numbers.
# "Successful marriages arranged so far" shows on the homepage; 0 hides it.
class SiteStat < ApplicationRecord
  validates :marriages_count, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  def self.current
    first || create!(marriages_count: 0)
  end

  # Never let this number break the homepage
  def self.marriages_count
    current.marriages_count.to_i
  rescue StandardError => e
    Rails.logger.warn("[site stats] #{e.class}: #{e.message}")
    0
  end
end
