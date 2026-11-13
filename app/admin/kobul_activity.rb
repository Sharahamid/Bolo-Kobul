# Weekly Kobul activity: how many 1st and 2nd Kobuls were sent, accepted and declined
# each week (Monday to Sunday, Bangladesh time), with acceptance rates, new profiles and
# chat messages.
#
# Counts come from the notifications each step creates, because a declined or cancelled
# Kobul is removed from the Kobul tables. Notifications of members who deleted their
# account are removed too, so those members drop out of the counts.
ActiveAdmin.register_page 'Kobul Activity' do
  menu parent: 'Reports', priority: 5, label: 'Kobul Activity'

  content title: 'Kobul Activity — week by week' do
    weeks_shown = (params[:weeks].presence || 12).to_i.clamp(4, 52)
    today = Time.zone.today
    first_monday = today.beginning_of_week(:monday) - (weeks_shown - 1).weeks
    week_sql = "date_trunc('week', (%s AT TIME ZONE 'UTC') AT TIME ZONE 'Asia/Dhaka')::date"

    patterns = {
      k1_sent:      'A butterfly has fluttered your way!%',
      k1_accepted:  'Good news! % has accepted your 1st Kobul!%',
      k1_declined:  'Sorry, % did not accept your 1st Kobul!%',
      k1_cancelled: 'You have cancelled your 1st Kobul request%',
      k2_sent:      '% would like to chat with you.%',
      k2_accepted:  '% has accepted your 2nd Kobul.%',
      k2_declined:  '% did not accept your 2nd Kobul!%'
    }

    since = first_monday.beginning_of_day.utc
    counts = patterns.transform_values do |pattern|
      Notification.where('content LIKE ?', pattern).where('created_at >= ?', since)
                  .group(Arel.sql(format(week_sql, 'created_at'))).count
                  .transform_keys(&:to_date)
    end
    counts[:profiles] = MarriageProfile.where('created_at >= ?', since)
                                       .group(Arel.sql(format(week_sql, 'created_at'))).count.transform_keys(&:to_date)
    counts[:messages] = Message.where('created_at >= ?', since)
                               .group(Arel.sql(format(week_sql, 'created_at'))).count.transform_keys(&:to_date)

    weeks = (0...weeks_shown).map { |i| first_monday + i.weeks }.reverse
    rows = weeks.map do |monday|
      row = counts.transform_values { |by_week| by_week[monday].to_i }
      row[:monday] = monday
      row
    end
    totals = counts.keys.index_with { |key| rows.sum { |r| r[key] } }

    rate = lambda do |accepted, declined|
      decided = accepted + declined
      decided.zero? ? '—' : "#{(accepted * 100.0 / decided).round}%"
    end
    num = ->(n) { n.zero? ? "<span class='bk-zero'>0</span>" : number_with_delimiter(n) }

    this_week = rows.first
    last_week = rows.second || this_week
    change = lambda do |now, before|
      return '' if before.zero? && now.zero?
      return "<span class='up'>new</span>" if before.zero?

      diff = ((now - before) * 100.0 / before).round
      diff >= 0 ? "<span class='up'>▲ #{diff}%</span>" : "<span class='down'>▼ #{diff.abs}%</span>"
    end
    max_sent = [rows.map { |r| [r[:k1_sent], r[:k2_sent]].max }.max.to_i, 1].max

    text_node raw(<<~HTML)
      <style>
        .bk-ka-grid { display:grid; grid-template-columns:repeat(4,1fr); gap:12px; margin-bottom:20px; }
        @media (max-width: 900px) { .bk-ka-grid { grid-template-columns:repeat(2,1fr); } }
        .bk-ka-stat { background:#fff; border:1px solid #e8e8e8; border-radius:8px; padding:16px; text-align:center; }
        .bk-ka-stat .val { font-size:26px; font-weight:bold; color:#C98700; }
        .bk-ka-stat .lbl { font-size:12px; color:#666; margin-top:4px; }
        .bk-ka-stat .sub { font-size:11px; margin-top:4px; color:#888; }
        .up { color:#1D7A55; font-weight:600; } .down { color:#C0392B; font-weight:600; }
        .bk-ka-note { font-size:12px; color:#777; margin:0 0 14px; line-height:1.6; }
        .bk-ka-weeks { margin:0 0 12px; font-size:12px; }
        .bk-ka-weeks a { display:inline-block; padding:4px 12px; margin-right:6px; border:1px solid #ddd; border-radius:999px; color:#412402; text-decoration:none; background:#fff; }
        .bk-ka-weeks a.on { background:#FFB627; border-color:#FFB627; font-weight:700; }
        .bk-ka-wrap { overflow-x:auto; background:#fff; border:1px solid #e8e8e8; border-radius:8px; }
        table.bk-ka { width:100%; border-collapse:collapse; font-size:13px; min-width:900px; }
        table.bk-ka th { background:#FFF3CC; color:#412402; font-weight:700; text-align:right; padding:9px 10px; white-space:nowrap; border-bottom:1px solid #F1E2B5; }
        table.bk-ka th:first-child, table.bk-ka td:first-child { text-align:left; }
        table.bk-ka th.grp { text-align:center; background:#FFE7A3; }
        table.bk-ka td { padding:8px 10px; text-align:right; border-bottom:1px solid #f2f2f2; white-space:nowrap; }
        table.bk-ka tr.now td { background:#FFFBF0; font-weight:600; }
        table.bk-ka tr.total td { background:#FAFAFA; font-weight:700; border-top:2px solid #eee; }
        table.bk-ka td.rate { color:#1D7A55; font-weight:700; }
        table.bk-ka td.sep, table.bk-ka th.sep { border-left:2px solid #F1E2B5; }
        .bk-zero { color:#ccc; }
        .bk-ka-bar { display:inline-block; height:6px; border-radius:3px; vertical-align:middle; margin-left:6px; }
        .bk-ka-bar.k1 { background:#FFB627; } .bk-ka-bar.k2 { background:#E86A8C; }
      </style>
    HTML

    text_node raw(<<~HTML)
      <div class="bk-ka-grid">
        <div class="bk-ka-stat">
          <div class="val">#{number_with_delimiter(this_week[:k1_sent])}</div>
          <div class="lbl">1st Kobuls sent this week</div>
          <div class="sub">#{change.call(this_week[:k1_sent], last_week[:k1_sent])} vs last week (#{last_week[:k1_sent]})</div>
        </div>
        <div class="bk-ka-stat">
          <div class="val">#{number_with_delimiter(this_week[:k1_accepted])}</div>
          <div class="lbl">1st Kobuls accepted this week</div>
          <div class="sub">Acceptance rate #{rate.call(this_week[:k1_accepted], this_week[:k1_declined])}</div>
        </div>
        <div class="bk-ka-stat">
          <div class="val">#{number_with_delimiter(this_week[:k2_sent])}</div>
          <div class="lbl">2nd Kobuls sent this week</div>
          <div class="sub">#{change.call(this_week[:k2_sent], last_week[:k2_sent])} vs last week (#{last_week[:k2_sent]})</div>
        </div>
        <div class="bk-ka-stat">
          <div class="val">#{number_with_delimiter(this_week[:k2_accepted])}</div>
          <div class="lbl">New chats opened this week</div>
          <div class="sub">Acceptance rate #{rate.call(this_week[:k2_accepted], this_week[:k2_declined])}</div>
        </div>
      </div>
      <p class="bk-ka-note">
        Weeks run Monday to Sunday (Bangladesh time); the top row is the week so far.
        <b>Acceptance rate</b> = accepted ÷ (accepted + declined), so Kobuls still waiting for an answer are not counted against it.
        Members who deleted their account are not included.
      </p>
      <div class="bk-ka-weeks">Show:
        #{[8, 12, 26, 52].map { |n| "<a href='?weeks=#{n}' class='#{'on' if n == weeks_shown}'>#{n} weeks</a>" }.join}
      </div>
    HTML

    body_rows = rows.each_with_index.map do |r, i|
      label = "#{r[:monday].strftime('%d %b')} – #{(r[:monday] + 6.days).strftime('%d %b %Y')}"
      label += ' (this week)' if i.zero?
      bar1 = (r[:k1_sent] * 60.0 / max_sent).round
      bar2 = (r[:k2_sent] * 60.0 / max_sent).round
      <<~ROW
        <tr class="#{'now' if i.zero?}">
          <td>#{label}</td>
          <td>#{num.call(r[:profiles])}</td>
          <td class="sep">#{num.call(r[:k1_sent])}<span class="bk-ka-bar k1" style="width:#{bar1}px"></span></td>
          <td>#{num.call(r[:k1_accepted])}</td>
          <td>#{num.call(r[:k1_declined])}</td>
          <td>#{num.call(r[:k1_cancelled])}</td>
          <td class="rate">#{rate.call(r[:k1_accepted], r[:k1_declined])}</td>
          <td class="sep">#{num.call(r[:k2_sent])}<span class="bk-ka-bar k2" style="width:#{bar2}px"></span></td>
          <td>#{num.call(r[:k2_accepted])}</td>
          <td>#{num.call(r[:k2_declined])}</td>
          <td class="rate">#{rate.call(r[:k2_accepted], r[:k2_declined])}</td>
          <td class="sep">#{num.call(r[:messages])}</td>
        </tr>
      ROW
    end.join

    text_node raw(<<~HTML)
      <div class="bk-ka-wrap">
        <table class="bk-ka">
          <thead>
            <tr>
              <th></th><th></th>
              <th class="grp sep" colspan="5">1st Kobul</th>
              <th class="grp sep" colspan="4">2nd Kobul (chat)</th>
              <th class="sep"></th>
            </tr>
            <tr>
              <th>Week</th><th>New profiles</th>
              <th class="sep">Sent</th><th>Accepted</th><th>Declined</th><th>Cancelled</th><th>Acceptance</th>
              <th class="sep">Sent</th><th>Accepted</th><th>Declined</th><th>Acceptance</th>
              <th class="sep">Chat messages</th>
            </tr>
          </thead>
          <tbody>
            #{body_rows}
            <tr class="total">
              <td>Total (#{weeks_shown} weeks)</td>
              <td>#{number_with_delimiter(totals[:profiles])}</td>
              <td class="sep">#{number_with_delimiter(totals[:k1_sent])}</td>
              <td>#{number_with_delimiter(totals[:k1_accepted])}</td>
              <td>#{number_with_delimiter(totals[:k1_declined])}</td>
              <td>#{number_with_delimiter(totals[:k1_cancelled])}</td>
              <td class="rate">#{rate.call(totals[:k1_accepted], totals[:k1_declined])}</td>
              <td class="sep">#{number_with_delimiter(totals[:k2_sent])}</td>
              <td>#{number_with_delimiter(totals[:k2_accepted])}</td>
              <td>#{number_with_delimiter(totals[:k2_declined])}</td>
              <td class="rate">#{rate.call(totals[:k2_accepted], totals[:k2_declined])}</td>
              <td class="sep">#{number_with_delimiter(totals[:messages])}</td>
            </tr>
          </tbody>
        </table>
      </div>
    HTML
  end
end
