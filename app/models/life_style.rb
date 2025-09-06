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
  serialize :dress_style,  Array
  serialize :living_with,  Array
  #Associations
  belongs_to :marriage_profile

  after_create :profile_progress_recalculate
  before_destroy :profile_progress_recalculate

  private

  def profile_progress_recalculate
    marriage_profile.progress_recalculate
  end
end
