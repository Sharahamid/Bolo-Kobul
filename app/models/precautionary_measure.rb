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

class PrecautionaryMeasure < ApplicationRecord
end
