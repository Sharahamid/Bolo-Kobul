# == Schema Information
#
# Table name: appearances
#
#  id                  :bigint           not null, primary key
#  body_art            :integer
#  body_type           :integer
#  complexion          :integer
#  eye_color           :string
#  eye_wear            :integer
#  hair_color          :string
#  hair_length         :string
#  hair_type           :string
#  is_hijab            :integer
#  is_niqab            :integer
#  physical_status     :integer
#  weight              :decimal(, )
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  marriage_profile_id :integer
#

class Appearance < ApplicationRecord


  #
  # enum, constant & attr
  #
  enum physical_status: %i[normal physically_challenged]
  enum complexion: %i[very_fair fair wheatish wheatish_brown dark]
  enum body_art: %i[yes no],_prefix: :ba
  enum body_type: %i[slim athletic moderate heavy]
  enum eye_wear: %i[yes no],_prefix: :ew
  enum is_hijab: %i[yes no],_prefix: :h
  enum is_niqab: %i[yes no],_prefix: :n

  #Associations
  belongs_to :marriage_profile

  #
  # Validations
  #
  after_create :profile_progress_recalculate
  after_destroy :profile_progress_recalculate

  def present_any?
    body_art.present? ||
    body_type.present? ||
    complexion.present? ||
    eye_color.present? ||
    eye_wear.present? ||
    hair_color.present? ||
    hair_length.present? ||
    hair_type.present? ||
    is_hijab.present? ||
    is_niqab.present? ||
    physical_status.present? ||
    weight.present?
  end

  private

  def profile_progress_recalculate
    marriage_profile.progress_recalculate
  end
end
