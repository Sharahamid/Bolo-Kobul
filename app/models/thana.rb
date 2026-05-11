# == Schema Information
#
# Table name: thanas
#
#  id          :bigint           not null, primary key
#  name        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  district_id :integer
#

class Thana < ApplicationRecord
  #Associations
  belongs_to :district
  has_many :unions, dependent: :destroy
  #validations
  validates :name, uniqueness: true
end
