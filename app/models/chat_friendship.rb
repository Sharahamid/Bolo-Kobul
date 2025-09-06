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

class ChatFriendship < ApplicationRecord
  #
  # Enums
  #
  enum status: %i[pending requested accepted blocked]

  #
  # Associations
  #
  belongs_to :marriage_profile
  belongs_to :chat_friend, class_name: 'MarriageProfile'

  #
  # instance methods
  #



end
