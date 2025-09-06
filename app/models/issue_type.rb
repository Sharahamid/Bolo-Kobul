# == Schema Information
#
# Table name: issue_types
#
#  id         :bigint           not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class IssueType < ApplicationRecord
  #
  # validations
  #
  validates_presence_of :name

end
