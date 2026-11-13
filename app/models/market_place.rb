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

  enum :status, %i[pending approved]

  # Online applications (/advertise): fee and how long a paid listing stays up
  LISTING_PRICE = 1000
  LISTING_DAYS = 365

  #Associations
  belongs_to :market_place_type
  has_many :orders
  has_one_attached :image
  has_one_attached :image2
  has_one_attached :image3

  # Shown on the site: approved, and its year not over yet (listings added by the admin
  # without an end date stay up until the admin changes them)
  scope :live, -> { approved.where('listed_until IS NULL OR listed_until > ?', Time.current) }

  before_save :start_listing_year
  after_update_commit :email_business_when_approved


  #
  # validations
  #
  validates_presence_of :name, :cost
  validate :image_validation
  with_options if: :submitted_online? do
    validates_presence_of :location, :about, :contact_name, :contact_phone, :contact_email
    validates :contact_email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
    validate :main_image_present
  end


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

  def paid?
    paid_at.present?
  end

  # Days left before the listing comes off the site (nil = no end date)
  def days_left
    listed_until && ((listed_until - Time.current) / 1.day).ceil
  end

  # Called by the daily task: 14 days before the year ends, remind the business once
  def self.send_renewal_reminders
    approved.where(submitted_online: true, reminder_sent_at: nil)
            .where(listed_until: Time.current..14.days.from_now)
            .find_each do |listing|
      next if listing.contact_email.blank?
      MarketPlaceMailer.renewal_reminder(listing).deliver_later
      listing.update_column(:reminder_sent_at, Time.current)
    rescue => e
      Rails.logger.error "Listing reminder failed for #{listing.id}: #{e.message}"
    end
  end

  def image_validation
    if image.attached?
      if image.blob.byte_size > 2000000
        image.delete
        errors.add(:base, "File size(max 2MB) too large!")
      elsif !image.blob.content_type.starts_with?('image/')
        image.delete
        errors.add(:base, "Not in an acceptable format!")
      end
    end
  end

  private

  def main_image_present
    errors.add(:base, I18n.t('listing.errors.photo_needed')) unless image.attached?
  end

  # A paid online listing gets its year from the day the admin approves it
  def start_listing_year
    if will_save_change_to_status? && approved? && submitted_online? && listed_until.nil?
      self.listed_until = LISTING_DAYS.days.from_now
    end
    # A new end date (e.g. renewed for another year): remind again before that one
    self.reminder_sent_at = nil if will_save_change_to_listed_until? && persisted?
  end

  def email_business_when_approved
    return unless saved_change_to_status? && approved? && submitted_online? && contact_email.present?
    MarketPlaceMailer.approved(self).deliver_later
  rescue => e
    Rails.logger.error "Listing approved email failed for #{id}: #{e.message}"
  end
end
