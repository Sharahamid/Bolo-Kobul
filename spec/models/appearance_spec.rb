# == Schema Information
#
# Table name: appearances
#
#  id                  :bigint           not null, primary key
#  body_art            :integer
#  body_type           :integer
#  complexion          :integer
#  eye_color           :string
#  eye_wear            :integer
#  hair_color          :string
#  hair_length         :string
#  hair_type           :string
#  is_hijab            :integer
#  is_niqab            :integer
#  physical_status     :integer
#  weight              :decimal(, )
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  marriage_profile_id :integer
#

require 'rails_helper'

RSpec.describe Appearance, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
