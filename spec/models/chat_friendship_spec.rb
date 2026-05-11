# == Schema Information
#
# Table name: chat_friendships
#
#  id                  :bigint           not null, primary key
#  status              :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  chat_friend_id      :integer
#  marriage_profile_id :integer
#

require 'rails_helper'

RSpec.describe ChatFriendship, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
