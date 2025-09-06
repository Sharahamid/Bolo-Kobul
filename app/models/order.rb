# == Schema Information
#
# Table name: orders
#
#  id                  :bigint           not null, primary key
#  customer_email      :string
#  customer_name       :string
#  customer_phone      :string
#  discount_amount     :decimal(, )
#  payment_method      :integer
#  price               :decimal(, )
#  product             :integer          default("butterfly")
#  promo_code          :string
#  quantity            :integer
#  status              :integer
#  sub_total_amount    :decimal(, )
#  total_amount        :decimal(, )
#  txn_no              :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  assisted_service_id :bigint
#  user_id             :integer
#
# Indexes
#
#  index_orders_on_assisted_service_id  (assisted_service_id)
#

class Order < ApplicationRecord
  #
  # enum & constants
  #

  enum status: %i[pending success failed]
  enum payment_method: %i[foster_payment]
  enum product: %i[butterfly assisted_service]

  #
  # associations
  #

  belongs_to :user, optional: true
  belongs_to :assisted_service, optional: true
  has_many :transactions

  #
  # Callbacks
  #
  after_commit :update_butterflies, :make_transaction

  #
  # instance methods
  #
  def discount_amount
    0
  end

  def transaction_check(tran_id)
    Transaction.find_by(bank_tran_id: tran_id)
  end

  def make_transaction
    if txn_no.present?
      transaction = Transaction.find_by(bank_tran_id: txn_no)
      if transaction.present?
        transactions.update(status: status)
      else
        transactions.create(order_id: id, discount_amount: discount_amount, amount: total_amount.to_f, status: status, bank_tran_id: txn_no)
      end
    end
  end

  private

  def update_butterflies
    if status == "success" && butterfly?
      user = self.user
      user.butterfly_number = user.butterfly_number.present? ? user.butterfly_number + quantity : quantity
      user.save
    end
  end
end
