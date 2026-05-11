class AdminSupportMailer < ApplicationMailer
  def new_ticket(ticket)
    @ticket = ticket
    mail(to: "support@bolokobul.com", subject: "New Support Ticket ##{ticket.id}")
  end
  def new_story
    @blog = params[:blog]
    mail(to: "support@bolokobul.com", subject: "New Success Story Submitted ##{@blog.id}")
  end
  def new_payment(order)
    @order = order
    mail(to: "support@bolokobul.com", subject: "New Payment Received - #{@order.customer_name}")
  end
end
