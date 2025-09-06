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

require 'rails_helper'

RSpec.describe Order, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
