# == Schema Information
#
# Table name: divisions
#
#  id         :bigint           not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  country_id :integer
#

class Division < ApplicationRecord
  #Associations
  belongs_to :country
  has_many :districts, dependent: :destroy
  #validations
  validates :name, uniqueness: true
end
