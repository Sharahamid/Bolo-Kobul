# == Schema Information
#
# Table name: privacy_settings
#
#  id                      :bigint           not null, primary key
#  current_occupation      :integer          default("private")
#  date_of_birth           :integer          default("private")
#  family_status           :integer          default("private")
#  family_type             :integer          default("private")
#  family_values           :integer          default("private")
#  gender                  :integer          default("public")
#  height_ft               :integer          default("private")
#  highest_education_level :integer          default("private")
#  physical_status         :integer          default("private")
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  marriage_profile_id     :integer
#

require 'rails_helper'

RSpec.describe PrivacySetting, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
