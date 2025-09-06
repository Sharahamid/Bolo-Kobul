# == Schema Information
#
# Table name: ad_locations
#
#  id         :bigint           not null, primary key
#  location   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class AdLocation < ApplicationRecord
  #
  # enum and constant
  #

  enum location: %i[home_page_left home_page_right profile_page]

  #
  # associations
  #

  has_many :ads, dependent: :destroy
end
