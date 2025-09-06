# == Schema Information
#
# Table name: favourites
#
#  id                   :bigint           not null, primary key
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  favourite_profile_id :integer
#  marriage_profile_id  :integer
#

require 'rails_helper'

RSpec.describe Favourite, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
