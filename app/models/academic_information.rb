# == Schema Information
#
# Table name: academic_informations
#
#  id                  :bigint           not null, primary key
#  degree              :string
#  end_date            :datetime
#  institution         :string
#  passing_year        :string
#  result              :integer
#  start_date          :datetime
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  marriage_profile_id :integer
#

# TODO: why passing_year is integer field?
class AcademicInformation < ApplicationRecord

  #
  # enum, constant & attr
  #



  #
  # Associations
  #

  belongs_to :marriage_profile

  #
  # callbacks
  #

  after_save :profile_progress_recalculate
  after_destroy :profile_progress_recalculate

  private

  # A fresh copy, so a section that was just removed is not still counted
  def profile_progress_recalculate
    MarriageProfile.find_by(id: marriage_profile_id)&.progress_recalculate
  end
end
