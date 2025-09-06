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
  serialize :cuisine,  Array
  serialize :read,  Array
  serialize :favourite_movie,  Array
  serialize :music,  Array
  serialize :favourite_tv_show,  Array
  serialize :favourite_sports_show,  Array
  serialize :fitness_activity,  Array
  serialize :hobby,  Array
  serialize :interest,  Array
  serialize :travel,  Array
  #Associations
  belongs_to :marriage_profile

  after_create :profile_progress_recalculate
  after_destroy :profile_progress_recalculate

  private

  def profile_progress_recalculate
    marriage_profile.progress_recalculate
  end
end
