# Personal live alerts for the signed-in member (e.g. "new message"), on every page
class AlertsChannel < ApplicationCable::Channel
  def subscribed
    stream_for current_user
    # The site or app is open, so waiting messages have been delivered
    ChatRoom.mark_delivered_for!(current_user)
  end

  # The page received a new-message alert: that message is now delivered
  def delivered(_data)
    ChatRoom.mark_delivered_for!(current_user)
  end
end
