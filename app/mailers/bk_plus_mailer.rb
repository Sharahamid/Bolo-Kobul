class BkPlusMailer < ApplicationMailer
  include LocaleHelper

  # Sent after a BK+ payment: welcomes a new member to BK+ (or confirms the extension)
  # and explains every BK+ feature. Switch: Admin > Messages On / Off.
  def welcome
    @order = params[:order]
    @user = params[:user] || @order&.user
    return if @user.nil? || @user.email.blank? || @user.email.to_s.end_with?('@bolokobul.local')

    @plan = @order.bk_plus_plan
    @until = @user.bk_plus_until
    @renewal = Order.where(user_id: @user.id, product: :bk_plus, status: :success).where.not(id: @order.id).exists?
    mail(to: @user.email,
         subject: t(@renewal ? 'email.subject.bk_plus_extended' : 'email.subject.bk_plus_welcome'))
  end
end
