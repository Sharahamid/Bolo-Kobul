# == Schema Information
#
# Table name: marriage_profiles
#
#  id                      :bigint           not null, primary key
#  about_my_self           :text
#  blood_group             :integer
#  date_of_birth           :datetime
#  description             :text
#  email                   :string
#  family_status           :integer
#  family_type             :integer
#  family_values           :integer
#  gender                  :integer
#  height_ft               :integer
#  height_inch             :integer
#  highest_education_level :integer
#  hometown                :text
#  identification_document :string
#  marital_status          :integer
#  name                    :string
#  nid_or_passport         :string
#  photo_1                 :string
#  photo_2                 :string
#  photo_3                 :string
#  present_address         :text
#  present_location        :text
#  profile_completeness    :integer          default(0)
#  profile_image           :string
#  relation                :integer
#  religion                :integer
#  slug                    :string
#  special_circumstances   :text
#  verified                :boolean
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  user_id                 :integer
#
# Indexes
#
#  index_marriage_profiles_on_slug  (slug) UNIQUE
#

require 'rails_helper'

RSpec.describe MarriageProfile, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
