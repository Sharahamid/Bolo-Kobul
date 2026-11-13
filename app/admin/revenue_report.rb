# Revenue month by month (Bangladesh time), split into butterflies, BK+ and Assisted Services.
# Only successful payments are counted.
ActiveAdmin.register_page 'Revenue' do
  menu parent: 'Reports', priority: 3, label: 'Revenue'

  content title: 'Revenue — month by month' do
    months_shown = (params[:months].presence || 12).to_i.clamp(3, 36)
    tz_month = "date_trunc('month', (orders.created_at AT TIME ZONE 'UTC') AT TIME ZONE 'Asia/Dhaka')::date"
    this_month = Time.current.in_time_zone('Asia/Dhaka').to_date.beginning_of_month
    first = this_month << (months_shown - 1)
    paid = Order.where(status: :success)
    since = first.in_time_zone('Asia/Dhaka').beginning_of_day.utc

    sums = paid.where('orders.created_at >= ?', since).group(Arel.sql(tz_month), :product).sum(:total_amount)
    counts = paid.where('orders.created_at >= ?', since).group(Arel.sql(tz_month), :product).count
    products = { 'butterfly' => 'Butterflies', 'bk_plus' => 'BK+', 'assisted_service' => 'Assisted Services' }
    get = ->(h, m, p) { h.find { |(month, prod), _| month.to_date == m && prod.to_s == p }&.last.to_d }

    months = (0...months_shown).map { |i| this_month << i }
    rows_data = months.map do |m|
      by = products.keys.index_with { |p| [get.call(sums, m, p), get.call(counts, m, p).to_i] }
      [m, by, by.values.sum { |v| v[0] }]
    end
    max_total = [rows_data.map(&:last).max.to_d, 1].max

    rows = rows_data.each_with_index.map do |(m, by, total), i|
      cells = products.keys.map { |p| amt, n = by[p]; amt.zero? ? "<span style='color:#ccc'>—</span>" : "#{bk_taka(amt)} <span style='color:#999'>(#{n})</span>" }
      label = m.strftime('%B %Y') + (i.zero? ? ' (so far)' : '')
      [label, *cells, "<b>#{bk_taka(total)}</b><span class='bkr-bar' style='width:#{(total * 80 / max_total).round}px'></span>"]
    end
    col_totals = products.keys.map { |p| bk_taka(rows_data.sum { |_, by, _| by[p][0] }) }
    grand = rows_data.sum(&:last)

    now_total = rows_data[0][2]
    last_total = rows_data[1] ? rows_data[1][2] : 0
    change = if last_total.zero? then now_total.zero? ? '' : "<span class='up'>new</span>"
             else d = ((now_total - last_total) * 100 / last_total).round; d >= 0 ? "<span class='up'>▲ #{d}%</span> vs last month" : "<span class='down'>▼ #{d.abs}%</span> vs last month"
             end
    all_time = paid.sum(:total_amount)

    text_node bk_report_css
    text_node bk_tiles([
      [bk_taka(now_total), 'This month so far', change],
      [bk_taka(last_total), 'Last month', nil],
      [bk_taka(grand), "Last #{months_shown} months", nil],
      [bk_taka(all_time), 'All time', "#{paid.count} payments"]
    ])
    text_node raw("<p class='bkr-note'>Successful payments only, by the month they were paid (Bangladesh time). The number in brackets is how many payments. Show: #{[6, 12, 24].map { |n| "<a href='?months=#{n}'#{' style="font-weight:700"' if n == months_shown}>#{n} months</a>" }.join(' · ')}</p>")
    text_node bk_table(['Month', ['Butterflies', 'r'], ['BK+', 'r'], ['Assisted Services', 'r'], 'Total'], rows,
                       total: ['Total', *col_totals, "<b>#{bk_taka(grand)}</b>"])
  end
end
