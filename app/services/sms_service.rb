require 'uri'
require 'open-uri'

# Sends a text message through the SMS gateway. Returns the gateway's reply, or nil
# when the message could not be sent (gateway down, slow or replying with an error),
# so a problem with the SMS provider never breaks the page the member is on.
class SmsService
  SEND_ERRORS = [OpenURI::HTTPError, SocketError, SystemCallError, IOError, Timeout::Error,
                 Net::OpenTimeout, Net::ReadTimeout, OpenSSL::SSL::SSLError, JSON::ParserError].freeze

  def self.call(msisdn, msg)
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
      receiver: msisdn,
      message: msg
    }

    uri.query = URI.encode_www_form( params )
    response = uri.open(open_timeout: 5, read_timeout: 15).read
    JSON.parse(response)&.first
  rescue *SEND_ERRORS => e
    Rails.logger.error("[sms] could not send to #{msisdn.to_s[0, 6]}…: #{e.class}: #{e.message}")
    nil
  end
end
