# == Schema Information
#
# Table name: thanas
#
#  id          :bigint           not null, primary key
#  name        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  district_id :integer
#

require 'rails_helper'

RSpec.describe Thana, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
