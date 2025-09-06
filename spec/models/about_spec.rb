# == Schema Information
#
# Table name: abouts
#
#  id            :bigint           not null, primary key
#  content       :text
#  content_type  :string
#  display_order :integer          default(0)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

require 'rails_helper'

RSpec.describe About, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
