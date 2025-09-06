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
    date = date.localtime
    date.strftime('%b %d') if date.present?
  end

  def format_date_messaging(date)
    date = date.localtime
    date.strftime('%b %e, %l:%M %p') if date.present?
  end

end
