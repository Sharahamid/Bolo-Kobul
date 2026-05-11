# == Schema Information
#
# Table name: cultural_values
#
#  id                     :bigint           not null, primary key
#  attend_religious_event :integer
#  birth_place            :integer
#  born_or_reverted       :integer
#  languages_spoken       :text
#  mother_tongue          :integer
#  nationality            :string
#  political_view         :text
#  religion               :integer
#  resident_type          :integer
#  willing_to_relocate    :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  marriage_profile_id    :integer
#

require 'rails_helper'

RSpec.describe CulturalValue, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
