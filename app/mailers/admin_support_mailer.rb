class AdminSupportMailer < ApplicationMailer
  def new_ticket(ticket)
    @ticket = ticket
    mail(to: "support@bolokobul.com", subject: "New Support Ticket ##{ticket.id}")
  end
  def new_story
    @blog = params[:blog]
    mail(to: "support@bolokobul.com", subject: "New Success Story Submitted ##{@blog.id}")
  end
  def account_deletion_requested(user)
    @user = user
    mail(to: "support@bolokobul.com", subject: "Account deletion requested - #{user.name}")
  end
  def profile_reported(report)
    @report = report
    urgent = report.reporter_count >= 3 ? 'URGENT - ' : ''
    mail(to: "support@bolokobul.com", subject: "#{urgent}Profile reported - #{report.reported_profile.unique_id} (#{report.reason_label})")
  end
  def new_payment(order)
    @order = order
    mail(to: "support@bolokobul.com", subject: "New Payment Received - #{@order.customer_name}")
  end

  private

  # Emails to the Bolo Kobul team are always in English
  def locale_recipient
    nil
  end
end
