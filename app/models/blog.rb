# == Schema Information
#
# Table name: blogs
#
#  id                    :bigint           not null, primary key
#  author                :string
#  email                 :string
#  married_life_duration :string
#  partner               :string
#  slug                  :string
#  started_at            :datetime
#  status                :integer          default("pending")
#  story                 :text
#  story_type            :integer          default("success_story")
#  title                 :string
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#
# Indexes
#
#  index_blogs_on_slug  (slug) UNIQUE
#

class Blog < ApplicationRecord
  #
  # enum & constants
  #

  enum :status, %i[pending approved]
  enum :story_type, %i[success_story blog wedding_tips relationship_advice horoscope_compatibility]
  has_one_attached :image

  #
  # Friendly ID (Slugify)
  #
  extend FriendlyId
  friendly_id :title, use: :slugged

  #
  # validations
  #

  validates_presence_of :title, :email, :story

  #
  # callbacks
  #

  # before_save :set_title

  # Photos are shown at these sizes (twice the size on screen, for sharp phone screens).
  # Members often upload 5-8 MB camera photos; the site makes a small copy for each size
  # once, and serves that instead of the original.
  IMAGE_SIZES = {
    thumb:  { resize_to_fill: [360, 360] },    # round photo on the home page (174px)
    card:   { resize_to_fill: [300, 300] },    # story cards on the blog pages (140px)
    normal: { resize_to_limit: [1200, 1200] }  # the full story page
  }.freeze

  def image_url(size = :normal)
    return '' unless image.attached?

    helpers = Rails.application.routes.url_helpers
    return helpers.rails_blob_path(image, only_path: true) unless image.variable?

    variant = image.variant(IMAGE_SIZES.fetch(size, IMAGE_SIZES[:normal]).merge(quality: 82, strip: true))
    helpers.rails_representation_path(variant, only_path: true)
  end

  private

  def set_title
    self.title = "#{author} & #{partner}'s Story" if title.nil?
  end
end
