class OrdersController < ApplicationController
  include ActionView::Rendering#view_context

  before_action :authenticate_user!, only: [:index, :new]
  before_action :set_user, :set_butterfly_price
  before_action :set_order_and_verify, only: [:success, :fail, :cancel]
  skip_before_action :verify_authenticity_token, only: [:success, :fail, :cancel]
  before_action :no_butterfly_purchases_in_play_app, only: [:new, :create]

  def index
    @orders = @user.orders.order('created_at desc')
  end

  # /orders/123 (old links, payment pages): the orders list shows every order
  def show
    redirect_to orders_path
  end

  def new
  end

  def create
    @order = Order.new(order_params)

    if @order.assisted_service?
      @order.assisted_service = AssistedService.find(params[:order][:assisted_service_id])
      @order.price = @order.assisted_service.price
    elsif @order.bk_plus?
      # BK+ needs a signed-in member and one of the plans on sale (Admin > BK+ Plans)
      return redirect_to(new_user_session_path) unless @user

      plan = BkPlusPlan.for_sale.find_by(id: params.dig(:order, :bk_plus_plan_id))
      return redirect_to(bk_plus_path, alert: t('bkx.plus.unavailable')) unless plan

      @order.bk_plus_plan = plan
      @order.quantity = 1
      @order.price = plan.price
    else
      @order.price =  @butterfly_unit_price
    end

    @order.sub_total_amount = @order&.quantity.present? ? @order.quantity * @order.price : 0
    @order.total_amount = @order.sub_total_amount - (@order&.promo_code.present? ? @order.discount_amount : 0)

    if @user
      @order.user = @user
      @order.customer_name = @user.name
      @order.customer_email = @user.email
      @order.customer_phone = @user.phone_number
    end

    if @order.save! && @order.update(status: "pending",
                                     txn_no: "TRAN_#{Time.now.to_i}#{SecureRandom.hex(4)}")
      res_body = JSON.parse(PaymentService.call @order.id)
      if res_body && res_body["result"] == 'true'
        uri = URI(res_body["payment_url"])
        # uri.query = {payment_id: res_body["data"]["payment_id"]}.to_query
        redirect_to uri.to_s
      else
        flash["danger"] = "Something went wrong!"
        redirect_to orders_path
      end
    else
      flash["danger"] = "#{@order.errors.full_messages.first}"
      redirect_to orders_path
    end
  end

  def ipn
    # callback from payment gateway
    # we have to verify payment in here
  end

  def success
    return finish_listing_payment if @order&.directory_listing?

    begin
      if @order&.success?
        flash["success"] = "This payment has already been confirmed."
      elsif @order
        res_body = JSON.parse(PaymentService.trxcheck(@order.txn_no))
        if res_body["pay_status"] == 'Successful'
          @order.update(status: "success")
          product_name = @order.butterfly? ? view_context.pluralize(@order.quantity, 'Butterfly') : (@order.bk_plus? ? "BK+ (#{@order.bk_plus_plan&.label_en || 'membership'})" : @order.assisted_service&.name)
          begin
            AdminSupportMailer.new_payment(@order).deliver_later
          rescue => e
            Rails.logger.error "Admin payment email failed: #{e.message}"
          end
          begin
            @order.user.notifications.create(
              content: "Your purchase was successful! You have received #{product_name}. Enjoy!",
              category: :purchased,
              notifiable: @order
            )
          rescue => e
            Rails.logger.error "Purchase notification failed: #{e.message}"
          end
          if @order.bk_plus?
            begin
              BkPlusMailer.with(order: @order, user: @order.user).welcome.deliver_later
            rescue => e
              Rails.logger.error "BK+ welcome email failed: #{e.message}"
            end
          end
          begin
            if @order.bk_plus?
              buyer = @order.user.reload
              until_text = buyer.bk_plus_until&.strftime('%-d %b %Y')
              bonus = @order.bk_plus_plan&.butterflies.to_i
              text = "Payment received. Welcome to BK+! Your #{@order.bk_plus_plan&.label_en} membership is active until #{until_text}"
              text += ", with #{bonus} bonus butterflies added" if bonus.positive?
              text += ". See who viewed you: bolokobul.com/bk-plus"
              SmsService.call(buyer.phone_number.to_s, text, kind: :bk_plus_purchase)
            else
              SmsService.call(
                @order.user.phone_number.to_s,
                "Your purchase was successful! You have received #{product_name}. Log in to use them: bolokobul.com",
                kind: :purchase
              )
            end
          rescue => e
            Rails.logger.error "Purchase SMS failed: #{e.message}"
          end
          flash["success"] = "Purchase successful! Your invoice has been sent to #{@order.user.email}"
        else
          flash["danger"] = "Payment could not be verified. Status: #{res_body['pay_status']}. Please contact support@bolokobul.com"
        end
      else
        flash["danger"] = "Order not found. Please contact support@bolokobul.com"
      end
    rescue => e
      Rails.logger.error "Payment success error: #{e.message}"
      flash["danger"] = "Your payment may have been processed. Please contact support@bolokobul.com with your transaction details."
    end
    if @order&.user.present?
      sign_in_order_user
      active_profile = @order.user.marriage_profiles.first
      if active_profile.present?
        redirect_to dashboard_marriage_profile_path(active_profile)
      else
        redirect_to new_marriage_profile_path
      end
    elsif current_active_profile.present?
      redirect_to dashboard_marriage_profile_path(current_active_profile)
    else
      redirect_to root_path
    end
  end

  def fail
    return listing_payment_not_done(:fail) if @order&.directory_listing?

    if @order
      @order.update(status: "failed") if @return_verified && @order.pending?
      product_name = @order.butterfly? ? "Butterfly" : (@order.bk_plus? ? "BK+ (#{@order.bk_plus_plan&.label_en || 'membership'})" : @order.assisted_service&.name)
      flash["danger"] = "Your #{product_name} purchase was not successful. Please try again."
    else
      flash["danger"] = "Something went wrong. Please contact support@bolokobul.com"
    end
    if @order&.user.present?
      sign_in_order_user
      redirect_to orders_path
    else
      redirect_to root_path
    end
  end

  def cancel
    return listing_payment_not_done(:cancel) if @order&.directory_listing?

    if @order
      @order.update(status: "failed") if @return_verified && @order.pending?
      product_name = @order.butterfly? ? "Butterfly" : (@order.bk_plus? ? "BK+ (#{@order.bk_plus_plan&.label_en || 'membership'})" : @order.assisted_service&.name)
      flash["warning"] = "Your #{product_name} purchase was cancelled. No payment has been taken."
    else
      flash["warning"] = "Your purchase was cancelled."
    end
    if @order&.user.present?
      sign_in_order_user
      redirect_to orders_path
    else
      redirect_to root_path
    end
  end

  private

  # Wedding Shopping List fee paid (/advertise): mark the listing paid, tell the team and
  # the business. The listing still waits for the admin's approval.
  def finish_listing_payment
    listing = @order.market_place
    begin
      if @order.success?
        flash[:success] = t('listing.flash.paid')
      else
        res_body = JSON.parse(PaymentService.trxcheck(@order.txn_no))
        if res_body['pay_status'] == 'Successful'
          @order.update(status: 'success')
          listing&.update_column(:paid_at, Time.current)
          begin
            AdminSupportMailer.new_listing(listing, @order).deliver_later
          rescue => e
            Rails.logger.error "Admin listing email failed: #{e.message}"
          end
          begin
            MarketPlaceMailer.received(listing, @order).deliver_later if listing&.contact_email.present?
          rescue => e
            Rails.logger.error "Listing receipt email failed: #{e.message}"
          end
          flash[:success] = t('listing.flash.paid')
          return redirect_to(advertise_path(paid: 1))
        else
          flash[:danger] = t('listing.flash.not_verified')
        end
      end
    rescue => e
      Rails.logger.error "Listing payment error: #{e.message}"
      flash[:danger] = t('listing.flash.not_verified')
    end
    redirect_to advertise_path(paid: (@order.reload.success? ? 1 : nil))
  end

  def listing_payment_not_done(outcome)
    @order.update(status: 'failed') if @return_verified && @order.pending?
    flash[:warning] = t(outcome == :cancel ? 'listing.flash.cancelled' : 'listing.flash.failed')
    redirect_to advertise_path
  end

  # Google Play's payments policy: no butterfly purchases inside the Play Store app
  # (assisted services are real-world services and may still be paid with aamarPay)
  def no_butterfly_purchases_in_play_app
    return unless play_store_app?
    return if action_name == 'create' && params.dig(:order, :product) == 'assisted_service'

    redirect_to root_path
  end

  def set_user
    @user = current_user
    @marriage_profile = current_active_profile
  end

  def set_butterfly_price
    @butterfly_unit_price = ButterflyConfig.last.present? ?
                              ButterflyConfig.last.butterfly_price : 0.0
  end

  # The payment gateway sends the customer back here. The order must match the URL,
  # and only a valid signed return token (added to the return URLs by PaymentService)
  # proves the visitor came from a real checkout for this order.
  def set_order_and_verify
    @order = Order.find_by(txn_no: params[:mer_txnid])
    @order = nil if @order && @order.id.to_s != params[:id].to_s
    @return_verified = @order.present? && PaymentService.valid_return_token?(@order, params[:rt])
  end

  # The session cookie is usually not sent when the gateway posts back, so the customer
  # is signed in again here, but only for a verified return.
  def sign_in_order_user
    sign_in @order.user if @return_verified && !user_signed_in?
  end

  def order_params
    params.require(:order).permit(
      :quantity, :payment_method, :promo_code, :customer_name, :customer_phone, :customer_email, :product, :assisted_service_id
    )
  end
end
