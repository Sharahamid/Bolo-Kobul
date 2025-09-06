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
  enum gender: %i[male female]
  bitmask :marital_status, as:  %i[unmarried widow_or_widower divorced separated]
  enum family_type: %i[joint_family nuclear_family does_not_matter]
  enum physical_status: %i[normal physically_challenged does_not_matter], _prefix: :ps
  enum family_values: %i[orthodox traditional moderate liberal does_not_matter], _prefix: :fv
  enum family_status: %i[middle_Class upper_middle_class rich/affluent does_not_matter], _prefix: :fs
  enum height_ft: %i[0 1 2 3 4 5 6 7 8]
  enum height_inch: %i[0 1 2 3 4 5 6 7 8 9 10 11], _prefix: :inch
  enum highest_education_level: %i[doctorate graduate post_graduate undergraduate intermediate school non_traditional_education diploma], _prefix: :pe

  serialize :hometown, Array
  serialize :present_location, Array
  serialize :blood_group, Array

  #Associations
  belongs_to :marriage_profile

  #validations
  before_validation do |partner_preference|
    partner_preference.blood_group.reject!(&:blank?) if partner_preference.blood_group
  end

  validates_presence_of :religion, :gender
  validates_presence_of :max_inch, if: :max_height?
  validates_presence_of :min_inch, if: :min_height?
end
