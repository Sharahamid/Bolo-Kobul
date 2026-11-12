require 'uri'
require 'open-uri'

# Sends a text message through the SMS gateway. Returns the gateway's reply, or nil
# when the message could not be sent (gateway down, slow or replying with an error),
# so a problem with the SMS provider never breaks the page the member is on.
class SmsService
  SEND_ERRORS = [OpenURI::HTTPError, SocketError, SystemCallError, IOError, Timeout::Error,
                 Net::OpenTimeout, Net::ReadTimeout, OpenSSL::SSL::SSLError, JSON::ParserError].freeze

  # kind names the message (e.g. :otp, :kobul1_sent, :purchase); each one can be switched
  # off in Admin > Manage Site > Messages On / Off
  def self.call(msisdn, msg, kind: :other)
    unless MessageSetting.sms_allowed?(kind)
      Rails.logger.info("[sms] not sent (#{kind} SMS switched off in admin)")
      return nil
    end

    if msg.blank? || msisdn.blank?
      return { success: 0, message: 'Please provide both phone number as well as message'}
    end

    uri =
      URI.parse(SECRETES.dig('sms', 'url'))
    params = {
      masking: 'NOMASK',
      userName: SECRETES.dig('sms', 'username'),
      password: SECRETES.dig('sms', 'password'),
      MsgType: 'TEXT',
      receiver: PhoneNumber.for_sms(msisdn),
      message: msg
    }

    uri.query = URI.encode_www_form( params )
    response = uri.open(open_timeout: 5, read_timeout: 15).read
    # The gateway's reply says whether the text went out (or e.g. "low balance");
    # see it with: grep "\[sms\]" log/production.log | tail -20
    Rails.logger.info("[sms] to #{params[:receiver].to_s[0, 6]}…: #{response.to_s.squish[0, 300]}")
    result = JSON.parse(response)&.first
    # The gateway answers even when it refuses to send (e.g. "Not Enough Balance"), with
    # success 0. That is a failed send, not a sent message.
    if result.is_a?(Hash) && [0, '0', false].include?(result['success'])
      alert_team(result['message'].to_s) if result['message'].to_s =~ /balance/i
      return nil
    end
    result
  rescue *SEND_ERRORS => e
    Rails.logger.error("[sms] could not send to #{msisdn.to_s[0, 6]}…: #{e.class}: #{e.message}")
    nil
  end

  # Emails support@bolokobul.com when the SMS balance runs out (at most every 6 hours)
  def self.alert_team(reason)
    return if Rails.cache.read('sms_balance_alert_sent')

    Rails.cache.write('sms_balance_alert_sent', true, expires_in: 6.hours)
    AdminSupportMailer.sms_problem(reason).deliver_later
  rescue StandardError => e
    Rails.logger.error("[sms] could not send the balance alert: #{e.class}: #{e.message}")
  end
end
