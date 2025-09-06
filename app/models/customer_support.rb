# == Schema Information
#
# Table name: customer_supports
#
#  id          :bigint           not null, primary key
#  description :text
#  email       :string
#  issue_type  :string
#  status      :integer          default("in_queue")
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  user_id     :integer
#

class CustomerSupport < ApplicationRecord
  #
  # enum & constants
  #
  enum status: %i[in_queue processing resolved]

  #
  #Associations
  #
  belongs_to :user
  has_many :replies, class_name: 'CustomerSupportReply'
  has_one_attached :customer_attachment

  #
  # validations
  #
  validates_presence_of :issue_type, :description
  validate :customer_attachment_validation

  after_update :send_notification, if: :saved_change_to_status?

  def customer_attachment_url(size = :normal)
    if customer_attachment.attached?
      Rails.application.routes.url_helpers.rails_blob_path(customer_attachment, only_path: true)
    else
      ''
    end
  end

  def customer_attachment_validation
    if customer_attachment.attached?
      if customer_attachment.blob.byte_size > 2000000
        self.customer_attachment = nil
        errors[:base] << "File size(max 2MB) too large!"
      elsif !customer_attachment.blob.content_type.starts_with?('image/')
        self.customer_attachment = nil
        errors[:base] << "Not an acceptable format!"
      end
    end
  end

  private

  def send_notification
    user.notifications.create(
      content: "Your submitted report status has been changed.",
      notifiable: self
    )
  end
end
