# == Schema Information
#
# Table name: suggested_profiles
#
#  id                  :bigint           not null, primary key
#  matching_percent    :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  marriage_profile_id :integer
#

require 'rails_helper'

RSpec.describe SuggestedProfile, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
