require 'uri'
require 'open-uri'

class SmsService
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
    response = uri.open.read
    JSON.parse(response)&.first
  end
end
