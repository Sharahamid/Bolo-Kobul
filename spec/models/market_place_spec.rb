# == Schema Information
#
# Table name: market_places
#
#  id                   :bigint           not null, primary key
#  about                :text
#  cost                 :decimal(, )
#  costing_unit         :string
#  experience           :text
#  facility             :text
#  link                 :string
#  location             :string
#  name                 :string
#  policy               :text
#  service_coverage     :string
#  status               :integer          default("pending")
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  market_place_type_id :integer
#

require 'rails_helper'

RSpec.describe MarketPlace, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
