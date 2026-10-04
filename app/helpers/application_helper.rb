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

  # Formatting that stored rich text (blogs, FAQs, policies, notifications...) may keep.
  # Anything that can run code - scripts, event handlers like onclick, javascript: links,
  # iframes, forms - is removed.
  RICH_TEXT_TAGS = (Rails::Html::SafeListSanitizer.allowed_tags.to_a +
                    %w[table thead tbody tfoot tr td th caption colgroup col u s strike font center figure figcaption]).freeze
  RICH_TEXT_ATTRIBUTES = (Rails::Html::SafeListSanitizer.allowed_attributes.to_a +
                          %w[style target rel colspan rowspan align color size]).freeze

  def safe_html(html)
    sanitize(html.to_s, tags: RICH_TEXT_TAGS, attributes: RICH_TEXT_ATTRIBUTES)
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
