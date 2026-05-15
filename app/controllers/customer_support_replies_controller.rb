class CustomerSupportRepliesController < ApplicationController
  before_action :authenticate_user!

  def create
    @customer_support = current_user.customer_supports.find(params[:customer_support_id])
    @reply = @customer_support.replies.build(reply_params)
    @reply.repliable = current_user
    if @reply.save
      redirect_back fallback_location: customer_supports_path, notice: 'Reply sent successfully!'
    else
      redirect_back fallback_location: customer_supports_path, alert: 'Could not send reply.'
    end
  end

  private

  def reply_params
    params.require(:customer_support_reply).permit(:message, :attachment)
  end
end
