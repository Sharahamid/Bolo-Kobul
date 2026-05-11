# == Schema Information
#
# Table name: suggested_profiles
#
#  id                  :bigint           not null, primary key
#  matching_percent    :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  marriage_profile_id :integer
#

# TODO: need to add other marriage_profile_id
class SuggestedProfile < ApplicationRecord
  #Associations
  belongs_to :marriage_profile
end
