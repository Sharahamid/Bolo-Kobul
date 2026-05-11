# == Schema Information
#
# Table name: designations
#
#  id         :bigint           not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Designation < ApplicationRecord


  def self.get_designation(id)
    if id.present?
      designation = self.find_by(id: id)
    end
  end

end
