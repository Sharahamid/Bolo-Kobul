# == Schema Information
#
# Table name: unions
#
#  id         :bigint           not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  thana_id   :integer
#

require 'rails_helper'

RSpec.describe Union, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
