# == Schema Information
#
# Table name: abouts
#
#  id            :bigint           not null, primary key
#  content       :text
#  content_type  :string
#  display_order :integer          default(0)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class About < ApplicationRecord
  #
  # validations
  #

  validates_presence_of :content, :content_type
  validates_uniqueness_of :content_type
end
