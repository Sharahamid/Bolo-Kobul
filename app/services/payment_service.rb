require 'uri'
require 'openssl'
require 'net/http'
require 'json'

class PaymentService
  def self.data(order)
    {
      "store_id": SECRETES.dig('aamarpay', 'store_id'),
      "tran_id": order.txn_no,
      "success_url": "#{SECRETES.dig('aamarpay', 'callback_url')}/orders/#{order.id}/success",
      "fail_url": "#{SECRETES.dig('aamarpay', 'callback_url')}/orders/#{order.id}/fail",
      "cancel_url": "#{SECRETES.dig('aamarpay', 'callback_url')}/orders/#{order.id}/cancel",
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
