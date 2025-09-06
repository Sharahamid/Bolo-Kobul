# == Schema Information
#
# Table name: marriage_informations
#
#  id                  :bigint           not null, primary key
#  have_children       :boolean
#  no_of_childrens     :integer
#  want_more_child     :boolean
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  marriage_profile_id :integer
#

class MarriageInformation < ApplicationRecord

  #
  # enum, constant & attr
  #

  #
  # Associations
  #
  belongs_to :marriage_profile

  after_create :profile_progress_recalculate
  after_destroy :profile_progress_recalculate

  private

  def profile_progress_recalculate
    marriage_profile.progress_recalculate
  end
end
