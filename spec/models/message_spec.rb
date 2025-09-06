# == Schema Information
#
# Table name: messages
#
#  id           :bigint           not null, primary key
#  body         :text
#  status       :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  chat_room_id :integer
#  recipient_id :integer
#  sender_id    :integer
#

require 'rails_helper'

RSpec.describe Message, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
