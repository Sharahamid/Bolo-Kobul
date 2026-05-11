# == Schema Information
#
# Table name: countries
#
#  id         :bigint           not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Country < ApplicationRecord
  #Associations
  has_many :divisions, dependent: :destroy
  #validations
  validates :name, uniqueness: true
end
