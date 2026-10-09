# == Schema Information
#
# Table name: life_styles
#
#  id                  :bigint           not null, primary key
#  dress_style         :string
#  drinker             :integer
#  food_habits         :integer
#  living_with         :string
#  smoker              :integer
#  specific_habits     :text
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  marriage_profile_id :integer
#

class LifeStyle < ApplicationRecord
  serialize :dress_style, type: Array, coder: YAML
  serialize :living_with, type: Array, coder: YAML
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
