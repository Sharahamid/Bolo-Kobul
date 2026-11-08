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

  # Removes one member's favourite (never another member's)
  def self.remove_from_favourite(owner_profile_id, favourite_profile_id)
    where(marriage_profile_id: owner_profile_id, favourite_profile_id: favourite_profile_id).destroy_all
  end
end
