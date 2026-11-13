# How many SMS and emails the site sends, week by week, and which kinds (counting starts from
# the day this report went live). Failed SMS are usually "not enough balance".
ActiveAdmin.register_page 'Messages Sent' do
  menu parent: 'Reports', priority: 7, label: 'Messages Sent'

  content title: 'Messages Sent — SMS and email' do
    weeks_shown = 12
    week_sql = "date_trunc('week', (created_at AT TIME ZONE 'UTC') AT TIME ZONE 'Asia/Dhaka')::date"
    this_monday = Time.current.in_time_zone('Asia/Dhaka').to_date.beginning_of_week(:monday)
    first = this_monday - (weeks_shown - 1).weeks
    since = first.in_time_zone('Asia/Dhaka').beginning_of_day.utc
    counts = MessageLog.where('created_at >= ?', since).group(Arel.sql(week_sql), :channel).count
    get = ->(m, ch) { counts.find { |(w, c), _| w.to_date == m && c == ch }&.last.to_i }
    started = MessageLog.minimum(:created_at)
    labels = MessageSetting::CATALOG.to_h { |key, _section, label| [key, label] }

    rows = (0...weeks_shown).map { |i| this_monday - i.weeks }.each_with_index.map do |m, i|
      failed = get.call(m, 'sms_failed')
      ["#{m.strftime('%d %b')} – #{(m + 6).strftime('%d %b %Y')}#{' (this week)' if i.zero?}",
       get.call(m, 'sms'), failed.zero? ? "<span style='color:#ccc'>0</span>" : "<span class='down'>#{failed}</span>", get.call(m, 'email')]
    end

    month_start = Time.current.in_time_zone('Asia/Dhaka').beginning_of_month
    month = MessageLog.where('created_at >= ?', month_start)
    by_kind = month.group(:channel, :kind).count.sort_by { |_, n| -n }.first(25).map do |(ch, kind), n|
      key = ch == 'email' ? "email.#{kind}" : "sms.#{kind}"
      [ch == 'email' ? 'Email' : (ch == 'sms_failed' ? "<span class='down'>SMS not sent</span>" : 'SMS'),
       bk_esc(labels[key] || kind), n]
    end

    text_node bk_report_css
    text_node bk_tiles([
      [month.where(channel: 'sms').count, 'SMS sent this month', nil],
      [month.where(channel: 'sms_failed').count, 'SMS that failed this month', 'Usually "not enough balance" - top up Boom Cast'],
      [month.where(channel: 'email').count, 'Emails sent this month', nil],
      [MessageLog.where(channel: 'sms').count, 'SMS sent since counting began', started ? "Counting since #{bk_dhaka(started)}" : 'Counting starts with the next message']
    ])
    text_node raw("<p class='bkr-note'>Counts only, no message content is stored. Switched-off messages (Manage Site &gt; Messages On / Off) are not sent and not counted. The SMS company does not share your balance with the site, so check the balance on the Boom Cast website; a rise in failed SMS is the warning sign.</p>")
    text_node bk_h('Week by week')
    text_node bk_table(['Week', ['SMS sent', 'r'], ['SMS failed', 'r'], ['Emails sent', 'r']], rows)
    text_node bk_h('This month by message')
    text_node bk_table(['Type', 'Message', ['Count', 'r']], by_kind, empty: 'Nothing sent this month yet.')
  end
end
