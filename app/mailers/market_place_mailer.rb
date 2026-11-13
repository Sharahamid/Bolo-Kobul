# Emails to businesses on the Wedding Shopping List (/advertise). Written in English.
# Switches: Admin > Messages On / Off ("Emails: to businesses").
class MarketPlaceMailer < ApplicationMailer
  # Payment received: the listing is waiting for the team's review
  def received(listing, order)
    @listing = listing
    @order = order
    mail(to: listing.contact_email, subject: "Bolo Kobul: we received your Wedding Shopping List application")
  end

  # The admin approved it: the listing is now on the site until listed_until
  def approved(listing)
    @listing = listing
    mail(to: listing.contact_email, subject: "Your business is now live on Bolo Kobul's Wedding Shopping List")
  end

  # 14 days before the year ends
  def renewal_reminder(listing)
    @listing = listing
    mail(to: listing.contact_email, subject: "Your Bolo Kobul listing ends on #{listing.listed_until&.strftime('%-d %b %Y')}")
  end
end
