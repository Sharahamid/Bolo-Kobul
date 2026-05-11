class CustomerSupportsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [:index]
  layout 'application', only: [:new, :create]

  def index
    if @user.present?
      @customer_supports = @user.customer_supports
    else
      render 'new'
    end
  end
  def new
    @customer_support = CustomerSupport.new
  end

  def create
    @customer_support = current_user.customer_supports.build(customer_params)
    if @customer_support.save
      redirect_back fallback_location: root_path, notice: 'Submitted Successfully.'
    else
      redirect_back fallback_location: root_path, notice: "#{@customer_support.errors.full_messages.first}"
    end
  end

  private

  def customer_params
    params.require(:customer_support).permit(:description, :issue_type, :customer_attachment)
  end

  def set_user
    @user = current_user
    @marriage_profile = current_active_profile
  end
end
