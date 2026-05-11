# == Schema Information
#
# Table name: notifications
#
#  id              :bigint           not null, primary key
#  category        :integer          default("default")
#  content         :text
#  is_read         :boolean          default(FALSE)
#  notifiable_type :string
#  will_email      :boolean          default(TRUE)
#  will_sms        :boolean          default(TRUE)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  notifiable_id   :integer
#  recipient_id    :integer
#  sender_id       :integer
#

class Notification < ApplicationRecord
  #
  # enum, accessor, constant
  #

  enum category: [:default, :purchased]
  attr_accessor :assign_to

  #
  # Associations
  #

  belongs_to :notifiable, polymorphic: true, optional: true
  belongs_to :recipient, class_name: 'User'

  #
  # callback
  #

  before_save :update_recipient
  after_create :enqueue_notifiers

  #
  # scope
  #

  scope :unread, ->{ where(is_read: false) }

  #
  # instance variable
  #

  def mark_read
    update_column(:is_read, true)
  end

  def update_recipient
    return unless assign_to.present?

    id, type = assign_to.split('__')
    case type
    when 'User'
      self.recipient = User.find_by(id: id)
    end
  end

  def enqueue_notifiers
    if recipient && is_read == false && (will_sms? || will_email?)
      NotificationWorker.perform_async id
    end
  end

  def send_sms
    if recipient.text_alert == "on"
      SmsService.call(
        recipient.phone_number.to_s,
        content + ". Visit: bolokobul.com"
      )
    end
  end

  def send_email
    NotificationMailer.with(notification: self)
      .send("#{category}_notification")
      .deliver_later
  end
end
