# == Schema Information
#
# Table name: family_members
#
#  id                  :bigint           not null, primary key
#  marital_status      :integer
#  name                :string
#  occupation          :integer
#  permanent_address   :string
#  relation            :integer
#  residence_type      :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  marriage_profile_id :integer
#

class FamilyMember < ApplicationRecord

  #
  # enum, constant & attr
  #
  enum relation: {
    father: 1,
    mother: 2,
    brother: 3,
    sister: 4,
    brother_in_law: 5,
    sister_in_law: 6,
    maternal_aunt: 7,
    paternal_aunt: 8,
    maternal_uncle: 9,
    paternal_uncle: 10,
    maternal_grandfather: 11,
    paternal_grandfather: 12,
    maternal_grandmother: 13,
    paternal_grandmother: 14,
    # grandfather: 15,
    cousin: 16
  }
  enum residence_type: %i[rented owned ]
  enum marital_status: %i[unmarried widow/Widower divorced separated married], _prefix: :fm
  enum occupation: %i[government_official defence private_service business self_employed homemaker unemployed student freelancer doctor engineer teacher retired], _prefix: :mo

  FAMILY_OCCUPATION_LABELS = {
    "government_official" => "Government Official",
    "defence"             => "Defence / Armed Forces",
    "private_service"     => "Private Service / Corporate",
    "business"            => "Business / Entrepreneur",
    "self_employed"       => "Self-Employed / Consultant",
    "homemaker"           => "Homemaker",
    "unemployed"          => "Unemployed / Looking for Work",
    "student"             => "Student",
    "freelancer"          => "Freelancer",
    "doctor"              => "Doctor / Medical Professional",
    "engineer"            => "Engineer",
    "teacher"             => "Teacher / Academic",
    "retired"             => "Retired"
  }.freeze

  def occupation_display
    FAMILY_OCCUPATION_LABELS[occupation] || occupation&.humanize
  end

  #Associations
  belongs_to :marriage_profile

  after_create :profile_progress_recalculate
  after_destroy :profile_progress_recalculate

  #
  # validations
  #

  validates_presence_of :name, :occupation, :residence_type, :relation

  private

  def profile_progress_recalculate
    marriage_profile.progress_recalculate
  end
end
