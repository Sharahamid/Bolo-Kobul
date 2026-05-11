class OrdersController < ApplicationController
  include ActionView::Rendering#view_context

  before_action :authenticate_user!, only: [:index, :new]
  before_action :set_user, :set_butterfly_price
  before_action :set_order_and_verify, only: [:success, :fail, :cancel]
  skip_before_action :verify_authenticity_token, only: [:success, :fail, :cancel]

  def index
    @orders = @user.orders.order('created_at desc')
  end

  def new
  end

  def create
    @order = Order.new(order_params)

    if @order.assisted_service?
      @order.assisted_service = AssistedService.find(params[:order][:assisted_service_id])
      @order.price = @order.assisted_service.price
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
                                     txn_no: "TRAN_" + Time.now.to_f.to_s)
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
    begin
      if @order
        res_body = JSON.parse(PaymentService.trxcheck(@order.txn_no))
        if res_body["pay_status"] == 'Successful'
          @order.update(status: "success")
          product_name = @order.butterfly? ? view_context.pluralize(@order.quantity, 'Butterfly') : @order.assisted_service&.name
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
          begin
            SmsService.call(
              @order.user.phone_number.to_s,
              "Your purchase was successful! You have received #{product_name}. Log in to use them: bolokobul.com"
            )
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
      sign_in @order.user unless user_signed_in?
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
    if @order
      @order.update(status: "failed")
      product_name = @order.butterfly? ? "Butterfly" : @order.assisted_service&.name
      flash["danger"] = "Your #{product_name} purchase was not successful. Please try again."
    else
      flash["danger"] = "Something went wrong. Please contact support@bolokobul.com"
    end
    if @order&.user.present?
      sign_in @order.user unless user_signed_in?
      redirect_to orders_path
    else
      redirect_to root_path
    end
  end

  def cancel
    if @order
      @order.update(status: "failed")
      product_name = @order.butterfly? ? "Butterfly" : @order.assisted_service&.name
      flash["warning"] = "Your #{product_name} purchase was cancelled. No payment has been taken."
    else
      flash["warning"] = "Your purchase was cancelled."
    end
    if @order&.user.present?
      sign_in @order.user unless user_signed_in?
      redirect_to orders_path
    else
      redirect_to root_path
    end
  end

  private

  def set_user
    @user = current_user
    @marriage_profile = current_active_profile
  end

  def set_butterfly_price
    @butterfly_unit_price = ButterflyConfig.last.present? ?
                              ButterflyConfig.last.butterfly_price : 0.0
  end

  def set_order_and_verify
    @order = Order.find_by(txn_no: params[:mer_txnid])
  end

  def order_params
    params.require(:order).permit(
      :quantity, :payment_method, :promo_code, :txn_no, :customer_name, :customer_phone, :customer_email, :product, :assisted_service_id
    )
  end
end
