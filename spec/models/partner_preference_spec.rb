# == Schema Information
#
# Table name: partner_preferences
#
#  id                      :bigint           not null, primary key
#  blood_group             :text
#  family_status           :integer
#  family_type             :integer
#  family_values           :integer
#  gender                  :integer
#  highest_education_level :integer
#  hometown                :text
#  marital_status          :integer
#  max_age                 :integer
#  max_height              :integer
#  max_inch                :integer
#  min_age                 :integer
#  min_height              :integer
#  min_inch                :integer
#  physical_status         :integer
#  present_location        :text
#  religion                :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  marriage_profile_id     :integer
#

require 'rails_helper'

RSpec.describe PartnerPreference, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
