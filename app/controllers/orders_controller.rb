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
    if @order
      res_body = JSON.parse(PaymentService.trxcheck(@order.txn_no))
      if res_body["pay_status"] == 'Successful'
        @order.update(status: "success")
        @order.user.notifications.create(
          content: "You have purchased #{view_context.pluralize(@order.quantity, @order.product.humanize)}.",
          category: :purchased,
          notifiable: @order
        )
        SmsService.call(
          @order.user.phone_number.to_s,
          "You have purchased #{view_context.pluralize(@order.quantity, @order.product.humanize)}. To use, visit: bolokobul.com"
        )
        flash["success"] = "You order is successful!"
      else
        flash["danger"] = "Payment status #{res_body['pay_status']}"
      end
    else
      flash["danger"] = "Something went wrong!"
    end
    redirect_to orders_path(butterfly: @order.product == 'butterfly' ? "bk_animate" : "")
  end

  def fail
    if @order
      @order.update(status: "failed")
      flash["danger"] = "You order has failed!"
    else
      flash["danger"] = "Something went wrong!"
    end
    redirect_to orders_path
  end

  def cancel
    if @order
      @order.update(status: "failed")
      flash["danger"] = "You order has cancelled!"
    else
      flash["danger"] = "Something went wrong!"
    end
    redirect_to orders_path
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
