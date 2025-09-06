# == Schema Information
#
# Table name: ads
#
#  id                    :bigint           not null, primary key
#  advertiser            :string
#  location              :integer          default("home_page_top")
#  price                 :integer          default(0)
#  status                :integer          default("pending")
#  title                 :string
#  url                   :string
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  advertiser_profile_id :integer
#

require 'rails_helper'

RSpec.describe Ad, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
