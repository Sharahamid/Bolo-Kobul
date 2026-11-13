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

  enum :status, %i[pending success failed]
  enum :payment_method, %i[foster_payment]
  enum :product, %i[butterfly assisted_service bk_plus]
  # Follow-up of a paid Assisted Service by the team (Admin > Reports > Assisted Services Sold)
  FULFILMENT_STATUSES = { 'to_do' => 'To do', 'in_progress' => 'In progress', 'done' => 'Done' }.freeze

  #
  # associations
  #

  belongs_to :user, optional: true
  belongs_to :assisted_service, optional: true
  belongs_to :bk_plus_plan, optional: true
  has_many :transactions

  #
  # Callbacks
  #
  after_commit :update_butterflies, :make_transaction, :apply_bk_plus
  before_save :stamp_fulfilled_at, if: :will_save_change_to_fulfilment_status?

  #
  # instance methods
  #
  def stamp_fulfilled_at
    self.fulfilled_at = fulfilment_status == 'done' ? Time.current : nil
  end

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
    if status == "success" && butterfly? && !butterflies_already_added?
      user = self.user
      user.butterfly_number = user.butterfly_number.present? ? user.butterfly_number + quantity : quantity
      begin
        user.save!
      rescue => e
        Rails.logger.error "Butterfly update failed for order #{id}: #{e.message}"
      end
    end
  end

  # BK+ bought: extend the membership by the plan's days and add its bonus butterflies
  # (once per order)
  def apply_bk_plus
    return unless status == 'success' && bk_plus? && !bk_plus_applied && user

    days = bk_plus_plan&.days.to_i
    bonus = bk_plus_plan&.butterflies.to_i
    return if days <= 0

    with_lock do
      unless bk_plus_applied
        start = [user.bk_plus_until, Time.current].compact.max
        user.update_columns(bk_plus_until: start + days.days,
                            butterfly_number: user.butterfly_number.to_i + bonus)
        update_column(:bk_plus_applied, true)
      end
    end
  rescue => e
    Rails.logger.error "BK+ activation failed for order #{id}: #{e.message}"
  end

  def butterflies_already_added?
    # Prevent double-adding by checking if a transaction exists for this order
    transactions.where(status: 1).exists?
  end
end
