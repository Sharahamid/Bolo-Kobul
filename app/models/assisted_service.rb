# == Schema Information
#
# Table name: assisted_services
#
#  id            :bigint           not null, primary key
#  display_order :integer          default(0)
#  name          :string           not null
#  page_content  :text
#  page_title    :string
#  price         :decimal(, )      default(0.0)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class AssistedService < ApplicationRecord
  has_many :orders
end
