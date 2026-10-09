# == Schema Information
#
# Table name: hobbies_and_interests
#
#  id                     :bigint           not null, primary key
#  cuisine                :text
#  favourite_book         :string
#  favourite_movie        :text
#  favourite_song         :string
#  favourite_sports_show  :text
#  favourite_tv_show      :text
#  fitness_activity       :text
#  hobby                  :text
#  interest               :text
#  music                  :text
#  music_type             :text
#  read                   :text
#  reading_type           :text
#  specific_entertainment :string
#  travel                 :text
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  marriage_profile_id    :integer
#

class HobbiesAndInterest < ApplicationRecord
  serialize :cuisine, type: Array, coder: YAML
  serialize :read, type: Array, coder: YAML
  serialize :favourite_movie, type: Array, coder: YAML
  serialize :music, type: Array, coder: YAML
  serialize :favourite_tv_show, type: Array, coder: YAML
  serialize :favourite_sports_show, type: Array, coder: YAML
  serialize :fitness_activity, type: Array, coder: YAML
  serialize :hobby, type: Array, coder: YAML
  serialize :interest, type: Array, coder: YAML
  serialize :travel, type: Array, coder: YAML
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
