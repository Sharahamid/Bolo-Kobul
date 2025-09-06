# == Schema Information
#
# Table name: chat_room_users
#
#  id                  :bigint           not null, primary key
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  chat_room_id        :integer
#  marriage_profile_id :integer
#

require 'rails_helper'

RSpec.describe ChatRoomUser, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
