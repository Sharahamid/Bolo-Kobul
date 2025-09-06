# == Schema Information
#
# Table name: districts
#
#  id          :bigint           not null, primary key
#  name        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  division_id :integer
#

require 'rails_helper'

RSpec.describe District, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
