# == Schema Information
#
# Table name: academic_informations
#
#  id                  :bigint           not null, primary key
#  degree              :string
#  end_date            :datetime
#  institution         :string
#  passing_year        :string
#  result              :integer
#  start_date          :datetime
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  marriage_profile_id :integer
#

require 'rails_helper'

RSpec.describe AcademicInformation, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
