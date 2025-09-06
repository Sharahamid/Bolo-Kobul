# == Schema Information
#
# Table name: life_styles
#
#  id                  :bigint           not null, primary key
#  dress_style         :string
#  drinker             :integer
#  food_habits         :integer
#  living_with         :string
#  smoker              :integer
#  specific_habits     :text
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  marriage_profile_id :integer
#

require 'rails_helper'

RSpec.describe LifeStyle, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
