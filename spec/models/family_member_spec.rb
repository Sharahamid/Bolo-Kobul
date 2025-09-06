# == Schema Information
#
# Table name: family_members
#
#  id                  :bigint           not null, primary key
#  marital_status      :integer
#  name                :string
#  occupation          :integer
#  permanent_address   :string
#  relation            :integer
#  residence_type      :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  marriage_profile_id :integer
#

require 'rails_helper'

RSpec.describe FamilyMember, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
