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

  enum status: %i[pending active inactive]
  enum location: %i[home_page_top home_page_bottom profile_page about_us_page]

  #
  # Associations
  #

  # Do not use advertiser_profile for now, rather using advertiser only for name
  belongs_to :advertiser_profile, optional: true
  has_one_attached :image

  #
  # instance method
  #

  def image_url(size = :normal)
    if image.attached?
      Rails.application.routes.url_helpers.rails_blob_path(image, only_path: true)
    else
      ''
    end
  end

  #
  # class methods
  #

  def self.about_us
    active.about_us_page.first&.image_url
  end

  def self.dashboard_top
    active.home_page_top.first&.image_url
  end

  def self.dashboard_bottom
    active.home_page_bottom.first&.image_url
  end
end
