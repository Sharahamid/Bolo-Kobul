# A browser or installed app that has agreed to receive phone/desktop notifications
class PushSubscription < ApplicationRecord
  belongs_to :user

  validates :endpoint, :p256dh, :auth, presence: true
  validates :endpoint, uniqueness: true
  validate :endpoint_is_known_push_service

  private

  def endpoint_is_known_push_service
    errors.add(:endpoint, 'is not a supported push service') unless WebPushService.allowed_endpoint?(endpoint)
  end
end
