# == Schema Information
#
# Table name: favourites
#
#  id                   :bigint           not null, primary key
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  favourite_profile_id :integer
#  marriage_profile_id  :integer
#

class Favourite < ApplicationRecord
  #
  # associations
  #

  # action taker
  belongs_to :marriage_profile
  # receiver
  belongs_to :favourite_profile, class_name: 'MarriageProfile'

  #
  # class methods
  #

  def self.remove_from_favourite(favourite_profile_id)
    favourite_profile = self.find_by(favourite_profile_id: favourite_profile_id)
    favourite_profile.destroy if favourite_profile.present?
  end
end
