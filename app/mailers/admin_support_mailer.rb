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
    urgent = report.reason == 'underage' || report.reporter_count >= 3 ? 'URGENT - ' : ''
    mail(to: "support@bolokobul.com", subject: "#{urgent}Profile reported - #{report.reported_profile.unique_id} (#{report.reason_label})")
  end
  # A business applied for the Wedding Shopping List and paid (/advertise)
  def new_listing(listing, order)
    @listing = listing
    @order = order
    mail(to: "support@bolokobul.com", subject: "New Wedding Shopping List entry (paid) - #{listing&.name} - please approve")
  end

  def new_payment(order)
    @order = order
    mail(to: "support@bolokobul.com", subject: "New Payment Received - #{@order.customer_name}")
  end

  # The SMS company refused to send texts (usually: balance used up). Codes are being
  # emailed instead until it is topped up.
  def sms_problem(reason)
    @reason = reason
    mail(to: "support@bolokobul.com", subject: "URGENT - SMS not sending: #{reason}")
  end

  private

  # Emails to the Bolo Kobul team are always in English
  def locale_recipient
    nil
  end
end
