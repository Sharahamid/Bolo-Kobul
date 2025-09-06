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

# TODO: instead of blocker id, is not it should have status
# field for keeping stack of status
class PartnerRequest < ApplicationRecord
  # Associations
  #belongs_to :sender, class_name: 'MarriageProfile', foreign_key: :sender_id
  #belongs_to :receiver, class_name: 'MarriageProfile', foreign_key: :recipient_id
end
