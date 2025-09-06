# == Schema Information
#
# Table name: unions
#
#  id         :bigint           not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  thana_id   :integer
#

class Union < ApplicationRecord
  #Associations
  belongs_to :thana
  #validations
  validates :name, uniqueness: true
end
