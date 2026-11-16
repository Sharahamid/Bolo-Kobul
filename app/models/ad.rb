# == Schema Information
#
# Table name: ads
#
#  id                    :bigint           not null, primary key
#  advertiser            :string
#  location              :integer          default("home_page_top")
#  price                 :integer          default(0)
#  status                :integer          default("pending")
#  title                 :string
#  url                   :string
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  advertiser_profile_id :integer
#

class Ad < ApplicationRecord
  #
  # constants and enum
  #

  enum :status, %i[pending active inactive]
  enum :location, %i[home_page_top home_page_bottom profile_page about_us_page]

  #
  # Associations
  #

  # Do not use advertiser_profile for now, rather using advertiser only for name
  belongs_to :advertiser_profile, optional: true
  has_one_attached :image

  #
  # instance method
  #

  # Ads are shown small (240px on the dashboard), so a resized copy is sent instead of the
  # uploaded file (often a 1 MB+ poster), which makes pages much faster on phones
  IMAGE_SIZES = {
    small:  { resize_to_limit: [600, 600] },   # dashboard side column
    normal: { resize_to_limit: [1000, 1000] }  # About page and profile pages
  }.freeze

  def image_url(size = :normal)
    return '' unless image.attached?

    helpers = Rails.application.routes.url_helpers
    return helpers.rails_blob_path(image, only_path: true) unless image.variable?

    variant = image.variant(IMAGE_SIZES.fetch(size, IMAGE_SIZES[:normal]).merge(quality: 82, strip: true))
    helpers.rails_representation_path(variant, only_path: true)
  rescue StandardError => e
    Rails.logger.warn("[ad image] #{id}: #{e.class}: #{e.message}")
    Rails.application.routes.url_helpers.rails_blob_path(image, only_path: true)
  end

  #
  # class methods
  #

  def self.about_us
    active.about_us_page.first&.image_url
  end

  # Active "Profile page" ad with a picture, shown on members' profile pages
  def self.for_profile_page
    active.profile_page.order(updated_at: :desc).detect { |ad| ad.image.attached? }
  end

  def self.dashboard_top
    active.home_page_top.first&.image_url
  end

  def self.dashboard_bottom
    active.home_page_bottom.first&.image_url
  end
end
