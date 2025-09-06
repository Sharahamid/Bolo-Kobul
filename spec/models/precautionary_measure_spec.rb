# == Schema Information
#
# Table name: precautionary_measures
#
#  id            :bigint           not null, primary key
#  content       :text
#  display_order :integer          default(0)
#  title         :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

require 'rails_helper'

RSpec.describe PrecautionaryMeasure, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
