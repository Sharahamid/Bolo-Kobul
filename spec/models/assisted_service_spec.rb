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

require 'rails_helper'

RSpec.describe AssistedService, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
