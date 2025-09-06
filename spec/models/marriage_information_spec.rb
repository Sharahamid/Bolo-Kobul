# == Schema Information
#
# Table name: marriage_informations
#
#  id                  :bigint           not null, primary key
#  have_children       :boolean
#  no_of_childrens     :integer
#  want_more_child     :boolean
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  marriage_profile_id :integer
#

require 'rails_helper'

RSpec.describe MarriageInformation, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
