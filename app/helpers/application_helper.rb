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

  # Stories typed in a plain text box: blank lines become paragraphs and single line
  # breaks are kept. Stories already written as HTML (paragraph/line-break tags) keep
  # their own layout.
  def formatted_story(text)
    text = text.to_s
    return safe_html(text) if text.match?(%r{<(p|br|div|li|h[1-6]|table)\b}i)

    safe_html(simple_format(text, {}, sanitize: false))
  end

  def format_date_chat(date)
    local_time_tag(date, :day)
  end

  def format_date_messaging(date)
    local_time_tag(date, :message)
  end

  # WhatsApp-style ticks under my own messages: one grey = sent, two grey = delivered,
  # two blue = read. public JS (room_channel.js) draws the same marks live.
  MESSAGE_TICK_PATHS = {
    sent: 'M4 8.5l3 3 6-7',
    double: 'M1 8.5l3 3 6-7M7.5 11.5l6-7'
  }.freeze

  def message_ticks(message, status)
    color = status == :read ? '#34B7F1' : '#9aa0a6'
    path = status == :sent ? MESSAGE_TICK_PATHS[:sent] : MESSAGE_TICK_PATHS[:double]
    label = { sent: 'Sent', delivered: 'Delivered', read: 'Read' }[status]
    content_tag(:span, class: 'bk-ticks', title: label, 'aria-label': label,
                       data: { created: message.created_at.utc.iso8601(3), status: status },
                       style: 'display:inline-flex; vertical-align:middle; margin-left:4px;') do
      content_tag(:svg, tag(:path, d: path, fill: 'none', stroke: color, 'stroke-width': 1.6,
                                   'stroke-linecap': 'round', 'stroke-linejoin': 'round'),
                  width: 16, height: 12, viewBox: '0 0 16 14', 'aria-hidden': true)
    end
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
