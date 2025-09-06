# == Schema Information
#
# Table name: chat_rooms
#
#  id         :bigint           not null, primary key
#  chat_type  :integer
#  is_private :boolean          default(FALSE)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

RSpec.describe ChatRoom, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
