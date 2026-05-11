# == Schema Information
#
# Table name: customer_supports
#
#  id          :bigint           not null, primary key
#  description :text
#  email       :string
#  issue_type  :string
#  status      :integer          default("in_queue")
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  user_id     :integer
#

require 'rails_helper'

RSpec.describe CustomerSupport, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
