# Personal live alerts for the signed-in member (e.g. "new message"), on every page
class AlertsChannel < ApplicationCable::Channel
  def subscribed
    stream_for current_user
  end
end
