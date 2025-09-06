# == Schema Information
#
# Table name: notifications
#
#  id              :bigint           not null, primary key
#  category        :integer          default("default")
#  content         :text
#  is_read         :boolean          default(FALSE)
#  notifiable_type :string
#  will_email      :boolean          default(TRUE)
#  will_sms        :boolean          default(TRUE)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  notifiable_id   :integer
#  recipient_id    :integer
#  sender_id       :integer
#

require 'rails_helper'

RSpec.describe Notification, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
