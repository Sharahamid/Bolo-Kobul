# == Schema Information
#
# Table name: partner_preferences
#
#  id                      :bigint           not null, primary key
#  blood_group             :text
#  family_status           :integer
#  family_type             :integer
#  family_values           :integer
#  gender                  :integer
#  highest_education_level :integer
#  hometown                :text
#  marital_status          :integer
#  max_age                 :integer
#  max_height              :integer
#  max_inch                :integer
#  min_age                 :integer
#  min_height              :integer
#  min_inch                :integer
#  physical_status         :integer
#  present_location        :text
#  religion                :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  marriage_profile_id     :integer
#

class PartnerPreference < ApplicationRecord
  BLOOD_GROUPS = %w[A+ A- B+ B- O+ O- AB+ AB-]

  #
  # enum, constant & attr
  #
  bitmask :religion, as: %i[islam hinduism christianity buddhism other]
  enum :gender, %i[male female]
  bitmask :marital_status, as:  %i[unmarried widow_or_widower divorced separated]
  enum :family_type, %i[joint_family nuclear_family does_not_matter]
  enum :physical_status, %i[normal physically_challenged does_not_matter], prefix: :ps
  enum :family_values, %i[orthodox traditional moderate liberal does_not_matter], prefix: :fv
  enum :family_status, %i[middle_Class upper_middle_class rich/affluent does_not_matter], prefix: :fs
  enum :highest_education_level, %i[doctorate graduate post_graduate undergraduate intermediate school non_traditional_education diploma], prefix: :pe

  serialize :hometown, type: Array, coder: YAML
  serialize :except_hometown, type: Array, coder: YAML
  serialize :present_location, type: Array, coder: YAML
  serialize :blood_group, type: Array, coder: YAML

  #Associations
  belongs_to :marriage_profile

  #validations
  before_validation do |partner_preference|
    partner_preference.blood_group.reject!(&:blank?) if partner_preference.blood_group
  end

  validates_presence_of :religion, :gender
  # A blank inch means 0 (5 ft = 5'0"); with no feet, the inch is cleared
  before_validation do |pp|
    pp.min_inch = pp.min_height.present? ? (pp.min_inch || 0) : nil
    pp.max_inch = pp.max_height.present? ? (pp.max_inch || 0) : nil
  end
  validate :max_height_not_below_min_height
  validate :max_age_not_below_min_age
  # Heights in feet and inches: minimum 3–6 ft, maximum 3–9 ft, inches 0–11 (checked when changed)
  validates :min_height, numericality: { only_integer: true, in: 3..6 }, allow_nil: true, if: :will_save_change_to_min_height?
  validates :max_height, numericality: { only_integer: true, in: 3..9 }, allow_nil: true, if: :will_save_change_to_max_height?
  validates :min_inch, :max_inch, numericality: { only_integer: true, in: 0..11 }, allow_nil: true

  private

  # Compares whole heights (5'4" = 64 inches); a blank min or max height means no limit
  def max_height_not_below_min_height
    return if min_height.blank? || max_height.blank?
    min_total = min_height.to_i * 12 + min_inch.to_i
    max_total = max_height.to_i * 12 + max_inch.to_i
    errors.add(:base, I18n.t('preference.height_range_error')) if max_total < min_total
  end

  # A blank min or max age means no limit on that side
  def max_age_not_below_min_age
    return if min_age.blank? || max_age.blank?
    errors.add(:max_age, I18n.t('preference.age_range_error')) if max_age.to_i < min_age.to_i
  end
end
