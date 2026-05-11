# == Schema Information
#
# Table name: permanent_addresses
#
#  id               :bigint           not null, primary key
#  address_details  :string
#  addressable_type :string
#  district         :integer
#  division         :integer
#  thana            :integer
#  union            :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  addressable_id   :integer
#

#TODO: why same polymorphic association with same name?
# Will not it conflict with other addressable ???
class PermanentAddress < ApplicationRecord
  #Associations
  belongs_to :addressable, polymorphic: true
end
