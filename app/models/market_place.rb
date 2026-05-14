# == Schema Information
#
# Table name: market_places
#
#  id                   :bigint           not null, primary key
#  about                :text
#  cost                 :decimal(, )
#  costing_unit         :string
#  experience           :text
#  facility             :text
#  link                 :string
#  location             :string
#  name                 :string
#  policy               :text
#  service_coverage     :string
#  status               :integer          default("pending")
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  market_place_type_id :integer
#

class MarketPlace < ApplicationRecord
  #
  # enum & constants
  #

  enum status: %i[pending approved]
  #Associations
  belongs_to :market_place_type
  has_one_attached :image
  has_one_attached :image2
  has_one_attached :image3


  #
  # validations
  #
  validates_presence_of :name, :cost
  validate :image_validation


  #
  # Instance methods
  #
  def image2_url
    if image2.attached?
      Rails.application.routes.url_helpers.rails_blob_path(image2, only_path: true)
    end
  end

  def image3_url
    if image3.attached?
      Rails.application.routes.url_helpers.rails_blob_path(image3, only_path: true)
    end
  end

  def image_url(size = :normal)
    if image.attached?
      Rails.application.routes.url_helpers.rails_blob_path(image, only_path: true)
    else
      ''
    end
  end

  def image_validation
    if image.attached?
      if image.blob.byte_size > 2000000
        image.delete
        errors[:base] << "File size(max 2MB) too large!"
      elsif !image.blob.content_type.starts_with?('image/')
        image.delete
        errors[:base] << "Not in an acceptable format!"
      end
    end
  end
end
