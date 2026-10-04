module ApplicationHelper

  def show_organization_name(id)
    org = Organization.find_by(id: id)
    org.name if org.present?
  end

  def get_date_format(date)
    date = date.localtime
    date.strftime("%b %d, %Y")
  end

  def get_datetime_format(datetime)
    date = datetime.localtime
    date.strftime("%d %b %Y %l:%M %p")
  end

  def format_date_chat(date)
    local_time_tag(date, :day)
  end

  def format_date_messaging(date)
    local_time_tag(date, :message)
  end

  # A time shown in the viewer's own time zone: public/local-times.js rewrites it in the
  # browser. Without JavaScript it shows Bangladesh time.
  def local_time_tag(time, format)
    return '' if time.blank?

    time = time.in_time_zone
    text = format == :day ? time.strftime('%b %d') : time.strftime('%b %e, %l:%M %p').squish
    content_tag(:time, text, datetime: time.utc.iso8601, class: 'js-local-time', data: { format: format })
  end

end
