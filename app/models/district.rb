# == Schema Information
#
# Table name: districts
#
#  id          :bigint           not null, primary key
#  name        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  division_id :integer
#

class District < ApplicationRecord
  #Associations
  belongs_to :division
  has_many :thanas, dependent: :destroy
  #validations
  validates :name, uniqueness: true

  scope :order_by_name, -> {order("name = 'Outside Bangladesh', name")}

  def self.get_district(id)
    if id.present?
      district = self.find_by(id: id)
    end
  end
end
