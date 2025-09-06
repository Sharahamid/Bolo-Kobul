# == Schema Information
#
# Table name: partner_requests
#
#  id           :bigint           not null, primary key
#  request_type :integer
#  status       :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  blocker_id   :integer
#  recipient_id :integer
#  sender_id    :integer
#

require 'rails_helper'

RSpec.describe PartnerRequest, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
