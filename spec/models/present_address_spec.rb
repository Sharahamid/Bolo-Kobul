# == Schema Information
#
# Table name: present_addresses
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

require 'rails_helper'

RSpec.describe PresentAddress, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
