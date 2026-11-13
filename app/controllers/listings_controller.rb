# "Advertise your wedding business" (/advertise): a business fills in its details and
# photos, pays the listing fee online (aamarPay) and the entry waits in
# Admin > Market Places as Pending until the admin approves it.
class ListingsController < ApplicationController
  MIN_SECONDS = 5 # people take longer than this to fill the form; bots do not

  before_action :no_payments_in_play_app

  def new
    @listing = MarketPlace.new
  end

  def create
    # Bot checks: a hidden field only bots fill in, and a form sent too quickly
    if params.dig(:market_place, :website_hp).present?
      return redirect_to(contact_path)
    end
    shown_at = Rails.application.message_verifier(:listing_form).verified(params[:form_shown].to_s) rescue nil
    if shown_at.nil? || Time.current.to_i - shown_at.to_i < MIN_SECONDS
      flash[:warning] = t('listing.flash.try_again')
      return redirect_to(advertise_path)
    end

    @listing = MarketPlace.new(listing_params.merge(status: :pending, submitted_online: true,
                                                    cost: listing_params[:cost].presence || 0))
    unless @listing.save
      return render(:new, status: :unprocessable_entity)
    end

    price = MarketPlace::LISTING_PRICE
    order = Order.create!(product: :directory_listing, market_place: @listing, quantity: 1,
                          price: price, sub_total_amount: price, total_amount: price,
                          customer_name: @listing.contact_name, customer_email: @listing.contact_email,
                          customer_phone: @listing.contact_phone, user: current_user,
                          status: :pending, txn_no: "TRAN_#{Time.now.to_i}#{SecureRandom.hex(4)}")
    res_body = JSON.parse(PaymentService.call(order.id)) rescue nil
    if res_body && res_body['result'] == 'true'
      redirect_to res_body['payment_url'], allow_other_host: true
    else
      flash[:danger] = t('listing.flash.payment_start_failed')
      redirect_to advertise_path
    end
  end

  def self.form_shown_token
    Rails.application.message_verifier(:listing_form).generate(Time.current.to_i)
  end

  private

  # Google Play's payments policy: the Play Store app links to the website instead
  def no_payments_in_play_app
    @in_play_app = play_store_app?
    redirect_to(contact_path) if @in_play_app && action_name == 'create'
  end

  def listing_params
    params.require(:market_place).permit(:name, :market_place_type_id, :location, :cost, :costing_unit,
                                         :about, :facility, :experience, :policy, :link,
                                         :image, :image2, :image3,
                                         :contact_name, :contact_phone, :contact_email)
  end
end
