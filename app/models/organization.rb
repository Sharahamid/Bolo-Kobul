# == Schema Information
#
# Table name: organizations
#
#  id         :bigint           not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Organization < ApplicationRecord


  def self.get_organization(id)
    if id.present?
      organization = self.find_by(id: id)
    end
  end

end
