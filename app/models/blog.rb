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

  enum status: %i[pending approved]
  enum story_type: %i[success_story blog]
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

  def image_url(size = :normal)
    if image.attached?
      Rails.application.routes.url_helpers.rails_blob_path(image, only_path: true)
    else
      ''
    end
  end

  private

  def set_title
    self.title = "#{author} & #{partner}'s Story" if title.nil?
  end
end
