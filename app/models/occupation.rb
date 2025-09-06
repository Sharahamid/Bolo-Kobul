# == Schema Information
#
# Table name: occupations
#
#  id                  :bigint           not null, primary key
#  company_name        :string
#  designation         :string
#  employment_status   :integer
#  end_date            :datetime
#  monthly_income      :integer
#  name                :integer
#  organization        :integer
#  start_date          :datetime
#  working_currently   :boolean
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  marriage_profile_id :integer
#

class Occupation < ApplicationRecord

  #
  # enum, constant & attr
  #
   enum monthly_income: %i[below_tk._15,000 tk._15,000_-_25,000 tk._25,000_-_50,000 tk._50,000_-_80,000 tk._80,000_-_100,000 above_tk._100,000]
   enum employment_status: %i[full_time part_time freelance contract temporary]
   enum name: %i[government defense private_sector business self_employed not_working]
  #
  # Associations
  #
  belongs_to :marriage_profile
  #
  # Validations
  #

  validates_presence_of :name, :organization, :employment_status, :monthly_income, :company_name, :designation, unless: :not_working?

  #
  # callbacks
  #

  after_create :profile_progress_recalculate
  after_destroy :profile_progress_recalculate
  before_save :reset_all_if_not_working

  private

  def profile_progress_recalculate
    marriage_profile.progress_recalculate
  end

  def reset_all_if_not_working
    if not_working?
      self.company_name = nil
      self.designation = nil
      self.employment_status = nil
      self.monthly_income = nil
      self.organization = nil
      self.start_date = nil
      self.end_date = nil
      self.working_currently = nil
    end
  end
end
