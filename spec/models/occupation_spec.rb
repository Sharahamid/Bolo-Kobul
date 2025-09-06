# == Schema Information
#
# Table name: occupations
#
#  id                  :bigint           not null, primary key
#  company_name        :string
#  designation         :string
#  employment_status   :integer
#  end_date            :datetime
#  monthly_income      :integer
#  name                :integer
#  organization        :integer
#  start_date          :datetime
#  working_currently   :boolean
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  marriage_profile_id :integer
#

require 'rails_helper'

RSpec.describe Occupation, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
