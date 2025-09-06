# == Schema Information
#
# Table name: privacy_policies
#
#  id            :bigint           not null, primary key
#  content       :text
#  display_order :integer          default(0)
#  title         :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class PrivacyPolicy < ApplicationRecord
  # Associations
  has_one_attached :pdf_content

  # Validations
  validate :pdf_content_validation

  def pdf_content_url(size = :normal)
    if pdf_content.attached?
      Rails.application.routes.url_helpers.rails_blob_path(pdf_content, only_path: true)
    else
      ''
    end
  end

  def pdf_content_validation
    if pdf_content.attached?
      if pdf_content.blob.byte_size > 2000000
        pdf_content.delete
        errors[:base] << "File size(max 2MB) too large!"
      elsif !pdf_content.blob.content_type.starts_with?('application/pdf')
        pdf_content.delete
        errors[:base] << "Not in an acceptable format!"
      end
    end
  end
end
