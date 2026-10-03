require 'uri'
require 'openssl'
require 'net/http'
require 'json'
require 'cgi'

class PaymentService
  RETURN_TOKEN_PURPOSE = :payment_return

  # Signed, expiring token added to the gateway return URLs so the return pages can
  # tell a genuine checkout return from a forged request
  def self.return_token(order)
    Rails.application.message_verifier(RETURN_TOKEN_PURPOSE)
         .generate(order.id, purpose: RETURN_TOKEN_PURPOSE, expires_in: 3.hours)
  end

  def self.valid_return_token?(order, token)
    return false if token.blank?
    Rails.application.message_verifier(RETURN_TOKEN_PURPOSE)
         .verified(token.to_s, purpose: RETURN_TOKEN_PURPOSE) == order.id
  rescue StandardError
    false
  end

  def self.return_url(order, outcome)
    "#{SECRETES.dig('aamarpay', 'callback_url')}/orders/#{order.id}/#{outcome}?rt=#{CGI.escape(return_token(order))}"
  end

  def self.data(order)
    {
      "store_id": SECRETES.dig('aamarpay', 'store_id'),
      "tran_id": order.txn_no,
      "success_url": return_url(order, 'success'),
      "fail_url": return_url(order, 'fail'),
      "cancel_url": return_url(order, 'cancel'),
      "amount": order.total_amount,
      "currency": "BDT",
      "signature_key": SECRETES.dig('aamarpay', 'signature_key'),
      "desc": "Bolokobul Butterfly Purchase",
      "cus_name": order.customer_name,
      "cus_email": order.customer_email,
      "cus_phone": order.customer_phone,
      "type": "json"
    }
  end

  def self.call(order_id)
    order = Order.find order_id

    if order
      uri = URI.parse(SECRETES.dig('aamarpay', 'payment_url'))
      header = {'Content-Type': 'application/json'}

      # Create the HTTP objects
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      request = Net::HTTP::Post.new(uri.request_uri, header)
      request.body = data(order).to_json

      # Send the request
      response = http.request(request)
      puts response.body
      response.body
    else
      nil
    end
  end

  def self.trxcheck(mer_txnid)
    uri = URI.parse(SECRETES.dig('aamarpay', 'trxcheck_url'))
    params = {
      request_id: mer_txnid,
      store_id: SECRETES.dig('aamarpay', 'store_id'),
      signature_key: SECRETES.dig('aamarpay', 'signature_key'),
      type: 'json'
    }
    uri.query = URI.encode_www_form(params)

    # Send the request
    response = Net::HTTP.get(uri)
    puts response
    response
  end
end
