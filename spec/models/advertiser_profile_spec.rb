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

require 'rails_helper'

RSpec.describe AdvertiserProfile, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
