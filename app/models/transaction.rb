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

class Transaction < ApplicationRecord
  #
  # enum and constants
  #

  enum status: %i[pending success failed canceled]

  #
  # associations
  #

  belongs_to :order
end
