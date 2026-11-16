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

  # Articles on almost the same topic always point to each other first ("You may also like")
  PAIRS = [
    %w[arranged-marriage-what-you-should-reveal-before-saying-kobul transparency-in-matchmaking-key-disclosures-before-arranged-marriages-in-bangladesh],
    %w[no-need-to-panic-arranged-marriages-are-not-what-you-think why-be-scared-of-arranged-marriage-busting-the-myths-and-embracing-the-journey],
    %w[wedding-photography-that-keeps-your-memories-alive wedding-day-photo-session-tips-for-arranged-marriages],
    %w[ensuring-the-new-bride-feels-like-family-not-a-guest how-to-help-the-bride-to-settle-down],
    %w[arranged-but-your-way-how-young-bangladesh-is-rewriting-marriage not-old-fashioned-just-smart-modern-arranged-love]
  ].freeze
  STOP_WORDS = %w[a an and the of to in for on with your you is are be not what how why when who it its
                  that this before after about from by at as or vs our their them do does can full].freeze

  # Up to `limit` published articles related to this one: its paired article first, then the
  # ones of the same kind sharing the most title words (e.g. the same star sign), then the newest
  def related(limit = 3)
    pool = Blog.approved.where.not(id: id).to_a
    picks = []
    partner_slugs = PAIRS.select { |pair| pair.include?(slug) }.flatten - [slug]
    picks += pool.select { |b| partner_slugs.include?(b.slug) }

    words = title_words
    scored = pool.reject { |b| picks.include?(b) }.map do |b|
      shared = (b.title_words & words).size
      [b, (b.story_type == story_type ? 1 : 0) + shared * 2, b.created_at.to_i]
    end
    picks += scored.select { |_, score, _| score.positive? }
                   .sort_by { |_, score, time| [-score, -time] }.map(&:first)
    picks += pool.reject { |b| picks.include?(b) }.sort_by { |b| -b.created_at.to_i }
    picks.first(limit)
  end

  def title_words
    title.to_s.downcase.scan(/[a-z]+/).reject { |w| w.length < 3 || STOP_WORDS.include?(w) }.uniq
  end

  private

  def set_title
    self.title = "#{author} & #{partner}'s Story" if title.nil?
  end
end
