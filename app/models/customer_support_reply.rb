# == Schema Information
#
# Table name: customer_support_replies
#
#  id                  :bigint           not null, primary key
#  message             :string
#  repliable_type      :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  customer_support_id :bigint           not null
#  repliable_id        :integer
#
# Indexes
#
#  index_customer_support_replies_on_customer_support_id  (customer_support_id)
#
# Foreign Keys
#
#  fk_rails_...  (customer_support_id => customer_supports.id)
#

class CustomerSupportReply < ApplicationRecord
  # Associations
  belongs_to :customer_support
  belongs_to :repliable, polymorphic: true

  # Validations
end
