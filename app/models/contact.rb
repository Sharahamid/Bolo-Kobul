# == Schema Information
#
# Table name: contacts
#
#  id         :bigint           not null, primary key
#  address    :string
#  contact    :string
#  content    :text
#  heading    :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Contact < ApplicationRecord
  #
  # validations
  #
  validates_presence_of :content, :address
end
