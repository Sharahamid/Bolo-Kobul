# == Schema Information
#
# Table name: privacy_settings
#
#  id                      :bigint           not null, primary key
#  current_occupation      :integer          default("private")
#  date_of_birth           :integer          default("private")
#  family_status           :integer          default("private")
#  family_type             :integer          default("private")
#  family_values           :integer          default("private")
#  gender                  :integer          default("public")
#  height_ft               :integer          default("private")
#  highest_education_level :integer          default("private")
#  physical_status         :integer          default("private")
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  marriage_profile_id     :integer
#

class PrivacySetting < ApplicationRecord
  #
  # enum, constant & attr
  #
  enum current_occupation: %i[public private], _prefix: true
  enum date_of_birth: %i[public private], _prefix: true
  enum family_status: %i[public private], _prefix: true
  enum family_type: %i[public private], _prefix: true
  enum family_values: %i[public private], _prefix: true
  enum gender: %i[public private], _prefix: true
  enum height_ft: %i[public private], _prefix: true
  enum highest_education_level: %i[public private], _prefix: true
  enum physical_status: %i[public private], _prefix: true
  #
  #Associations
  #
  belongs_to :marriage_profile
  #
  # Validations
  #

  def update_privacy(column)
    value = self.column == 'public' ? 'private' : 'public'
    self.update(column: value)
  end
end
