# == Schema Information
#
# Table name: process_flows
#
#  id            :bigint           not null, primary key
#  content       :text
#  display_order :integer          default(0)
#  title         :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class ProcessFlow < ApplicationRecord
  # Associations
  has_one_attached :process_image

  # Validations
  validates_presence_of :title
  validate :process_image_validation

  def process_image_url(size = :normal)
    if process_image.attached?
      Rails.application.routes.url_helpers.rails_blob_path(process_image, only_path: true)
    else
      ''
    end
  end

  def process_image_validation
    if process_image.attached?
      if process_image.blob.byte_size > 2000000
        process_image.delete
        errors[:base] << "File size(max 2MB) too large!"
      elsif !process_image.blob.content_type.starts_with?('image/')
        process_image.delete
        errors[:base] << "Not in an acceptable format!"
      end
    end
  end
end
