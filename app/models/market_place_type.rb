# == Schema Information
#
# Table name: market_place_types
#
#  id         :bigint           not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class MarketPlaceType < ApplicationRecord
  #
  # Associations
  #
  has_many :market_places, dependent: :destroy

  #
  # Validations
  #
  validates_presence_of :name
  validates_uniqueness_of :name
end
