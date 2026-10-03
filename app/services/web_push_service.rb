require 'openssl'
require 'base64'
require 'json'
require 'net/http'
require 'uri'

# Sends Web Push notifications (RFC 8030) with VAPID authentication (RFC 8292)
# and aes128gcm payload encryption (RFC 8291), using only Ruby's OpenSSL.
#
# Configuration (config/application.yml):
#   VAPID_PUBLIC_KEY  - base64url, 65-byte uncompressed P-256 point
#   VAPID_PRIVATE_KEY - base64url, 32-byte P-256 private key
#   VAPID_SUBJECT     - contact for the push services, e.g. mailto:support@bolokobul.com
class WebPushService
  # Only these push services are contacted, so a forged subscription can't make
  # the server send requests to arbitrary or internal addresses
  ALLOWED_HOST_SUFFIXES = %w[
    fcm.googleapis.com
    push.services.mozilla.com
    push.apple.com
    notify.windows.com
  ].freeze

  RECORD_SIZE = 4096
  TTL_SECONDS = 24 * 60 * 60

  class << self
    def configured?
      ENV['VAPID_PUBLIC_KEY'].present? && ENV['VAPID_PRIVATE_KEY'].present?
    end

    def public_key
      ENV['VAPID_PUBLIC_KEY'].to_s.strip
    end

    def allowed_endpoint?(endpoint)
      uri = URI.parse(endpoint.to_s)
      return false unless uri.is_a?(URI::HTTPS) && uri.host.present?
      host = uri.host.downcase
      ALLOWED_HOST_SUFFIXES.any? { |suffix| host == suffix || host.end_with?(".#{suffix}") }
    rescue URI::InvalidURIError
      false
    end

    # Sends one notification. Returns :ok, :gone (subscription removed) or :failed.
    def deliver(subscription, payload)
      return :failed unless configured? && allowed_endpoint?(subscription.endpoint)

      body = encrypt(payload.to_json, subscription.p256dh, subscription.auth)
      uri = URI.parse(subscription.endpoint)

      request = Net::HTTP::Post.new(uri.request_uri)
      request['TTL'] = TTL_SECONDS.to_s
      request['Urgency'] = 'normal'
      request['Content-Type'] = 'application/octet-stream'
      request['Content-Encoding'] = 'aes128gcm'
      request['Authorization'] = "vapid t=#{vapid_jwt("#{uri.scheme}://#{uri.host}")}, k=#{public_key}"
      request.body = body

      response = Net::HTTP.start(uri.host, uri.port, use_ssl: true, open_timeout: 5, read_timeout: 10) do |http|
        http.request(request)
      end

      case response.code.to_i
      when 200..299
        :ok
      when 404, 410
        subscription.destroy
        :gone
      else
        Rails.logger.warn("[WebPush] #{uri.host} responded #{response.code}: #{response.body.to_s[0, 200]}")
        :failed
      end
    rescue StandardError => e
      Rails.logger.warn("[WebPush] delivery failed: #{e.class}: #{e.message}")
      :failed
    end

    # Encrypts a payload for one subscription (RFC 8291, single aes128gcm record).
    # as_key and salt can be passed in for testing only.
    def encrypt(plaintext, p256dh, auth, as_key: nil, salt: nil)
      ua_public = decode64(p256dh)
      auth_secret = decode64(auth)
      group = OpenSSL::PKey::EC::Group.new('prime256v1')

      as_key ||= OpenSSL::PKey::EC.generate('prime256v1')
      as_public = as_key.public_key.to_bn.to_s(2)
      ua_point = OpenSSL::PKey::EC::Point.new(group, OpenSSL::BN.new(ua_public, 2))
      ecdh_secret = as_key.dh_compute_key(ua_point)

      salt ||= OpenSSL::Random.random_bytes(16)
      ikm = hkdf(auth_secret, ecdh_secret, "WebPush: info\x00".b + ua_public + as_public, 32)
      cek = hkdf(salt, ikm, "Content-Encoding: aes128gcm\x00".b, 16)
      nonce = hkdf(salt, ikm, "Content-Encoding: nonce\x00".b, 12)

      cipher = OpenSSL::Cipher.new('aes-128-gcm').encrypt
      cipher.key = cek
      cipher.iv = nonce
      ciphertext = cipher.update(plaintext.b + "\x02".b) + cipher.final + cipher.auth_tag

      header = salt + [RECORD_SIZE].pack('N') + [as_public.bytesize].pack('C') + as_public
      header + ciphertext
    end

    def vapid_jwt(audience)
      header = encode64({ typ: 'JWT', alg: 'ES256' }.to_json)
      claims = encode64({
        aud: audience,
        exp: Time.now.to_i + 12 * 60 * 60,
        sub: ENV['VAPID_SUBJECT'].presence || 'mailto:support@bolokobul.com'
      }.to_json)
      signing_input = "#{header}.#{claims}"
      der = vapid_key.sign(OpenSSL::Digest::SHA256.new, signing_input)
      "#{signing_input}.#{encode64(der_to_raw_signature(der))}"
    end

    # Returns { public_key:, private_key: } as base64url strings
    def generate_vapid_keys
      key = OpenSSL::PKey::EC.generate('prime256v1')
      {
        public_key: encode64(key.public_key.to_bn.to_s(2)),
        private_key: encode64(key.private_key.to_s(2).rjust(32, "\x00".b))
      }
    end

    private

    def vapid_key
      @vapid_key = nil if @vapid_key_source != ENV['VAPID_PRIVATE_KEY']
      @vapid_key_source = ENV['VAPID_PRIVATE_KEY']
      @vapid_key ||= ec_key_from_raw(decode64(ENV['VAPID_PRIVATE_KEY']), decode64(public_key))
    end

    # Builds an EC key from raw bytes via DER, which works on old and new Ruby/OpenSSL
    def ec_key_from_raw(private_bytes, public_bytes)
      der = OpenSSL::ASN1::Sequence.new([
        OpenSSL::ASN1::Integer.new(1),
        OpenSSL::ASN1::OctetString.new(private_bytes),
        OpenSSL::ASN1::ObjectId.new('prime256v1', 0, :EXPLICIT),
        OpenSSL::ASN1::BitString.new(public_bytes, 1, :EXPLICIT)
      ]).to_der
      OpenSSL::PKey::EC.new(der)
    end

    def der_to_raw_signature(der)
      r, s = OpenSSL::ASN1.decode(der).value.map { |part| part.value.to_s(2).rjust(32, "\x00".b) }
      r + s
    end

    def hkdf(salt, ikm, info, length)
      prk = OpenSSL::HMAC.digest('SHA256', salt, ikm)
      OpenSSL::HMAC.digest('SHA256', prk, info + "\x01".b)[0, length]
    end

    def encode64(bytes)
      Base64.urlsafe_encode64(bytes, padding: false)
    end

    def decode64(text)
      text = text.to_s.strip.tr('+/', '-_').delete('=')
      Base64.urlsafe_decode64(text + '=' * ((4 - text.length % 4) % 4))
    end
  end
end
