# One row per SMS or email the site sends (no content, just the kind), for Admin > Reports >
# Messages Sent. Logging never stops a message from going out.
class MessageLog < ApplicationRecord
  def self.record(channel, kind)
    create(channel: channel.to_s, kind: kind.to_s, created_at: Time.current)
  rescue StandardError => e
    Rails.logger.warn("[message_log] not recorded: #{e.class}")
    nil
  end
end
