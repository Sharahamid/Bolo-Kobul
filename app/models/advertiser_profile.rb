# == Schema Information
#
# Table name: advertiser_profiles
#
#  id            :bigint           not null, primary key
#  company_name  :string
#  email         :string
#  name          :string
#  total_earning :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  user_id       :integer
#

class AdvertiserProfile < ApplicationRecord
  #Associations
  belongs_to :user
  has_many :ads, dependent: :destroy
end
