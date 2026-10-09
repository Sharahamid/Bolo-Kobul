# == Schema Information
#
# Table name: cultural_values
#
#  id                     :bigint           not null, primary key
#  attend_religious_event :integer
#  birth_place            :integer
#  born_or_reverted       :integer
#  languages_spoken       :text
#  mother_tongue          :integer
#  nationality            :string
#  political_view         :text
#  religion               :integer
#  resident_type          :integer
#  willing_to_relocate    :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  marriage_profile_id    :integer
#

class CulturalValue < ApplicationRecord

  serialize :languages_spoken, type: Array, coder: YAML
  #Associations
  belongs_to :marriage_profile

  after_save :profile_progress_recalculate
  after_destroy :profile_progress_recalculate

  private

  # A fresh copy, so a section that was just removed is not still counted
  def profile_progress_recalculate
    MarriageProfile.find_by(id: marriage_profile_id)&.progress_recalculate
  end
end
