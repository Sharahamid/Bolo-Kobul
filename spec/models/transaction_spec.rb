# == Schema Information
#
# Table name: transactions
#
#  id                  :bigint           not null, primary key
#  amount              :decimal(, )
#  card_issuer         :string
#  card_no             :string
#  card_type           :string
#  currency            :string
#  currency_amount     :decimal(, )
#  discount_amount     :decimal(, )
#  discount_percentage :decimal(, )
#  status              :integer
#  transaction_by      :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  bank_tran_id        :string
#  order_id            :integer
#

require 'rails_helper'

RSpec.describe Transaction, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
