# Shared look for the admin report pages (Admin > Reports): stat boxes and tables
module AdminReportHelper
  # Short one-line preview of long text (HTML removed) for admin lists
  def admin_preview(text, length = 90)
    truncate(strip_tags(text.to_s).squish, length: length)
  end

  def bk_report_css
    <<~HTML.html_safe
      <style>
        .bkr-grid { display:grid; grid-template-columns:repeat(4,1fr); gap:12px; margin-bottom:16px; }
        @media (max-width: 900px) { .bkr-grid { grid-template-columns:repeat(2,1fr); } }
        .bkr-stat { background:#fff; border:1px solid #e8e8e8; border-radius:8px; padding:16px; text-align:center; }
        .bkr-stat .val { font-size:26px; font-weight:bold; color:#C98700; }
        .bkr-stat .lbl { font-size:12px; color:#666; margin-top:4px; }
        .bkr-stat .sub { font-size:11px; margin-top:4px; color:#888; }
        .bkr-h { display:flex; justify-content:space-between; align-items:center; margin:22px 0 8px; gap:12px; flex-wrap:wrap; }
        .bkr-h h3 { margin:0; color:#412402; font-size:16px; }
        .bkr-dl { font-size:12px; padding:5px 12px; border:1px solid #FFB627; border-radius:999px; color:#412402; text-decoration:none; background:#FFF3CC; }
        .bkr-wrap { overflow-x:auto; background:#fff; border:1px solid #e8e8e8; border-radius:8px; }
        table.bkr { width:100%; border-collapse:collapse; font-size:13px; }
        table.bkr th { background:#FFF3CC; color:#412402; font-weight:700; text-align:left; padding:9px 10px; white-space:nowrap; border-bottom:1px solid #F1E2B5; }
        table.bkr td { padding:8px 10px; border-bottom:1px solid #f2f2f2; white-space:nowrap; }
        table.bkr th.r, table.bkr td.r { text-align:right; }
        table.bkr tr.total td { background:#FAFAFA; font-weight:700; border-top:2px solid #eee; }
        .bkr-empty { background:#fff; border:1px dashed #ddd; border-radius:8px; padding:14px; color:#888; font-size:13px; margin:0; }
        .bkr-note { font-size:12px; color:#777; margin:0 0 14px; line-height:1.6; }
        .bkr-bar { display:inline-block; height:8px; border-radius:4px; background:#FFB627; vertical-align:middle; margin-left:8px; }
        .bkr-chip { display:inline-block; padding:2px 10px; border-radius:999px; font-size:12px; font-weight:700; }
        .bkr-chip.todo { background:#FDECEC; color:#B42318; } .bkr-chip.prog { background:#FFF3CC; color:#8A5A00; } .bkr-chip.done { background:#E7F6EE; color:#1D7A55; }
        .up { color:#1D7A55; font-weight:600; } .down { color:#C0392B; font-weight:600; } .warn { color:#B45309; font-weight:700; }
      </style>
    HTML
  end

  # tiles: [[value, label, sub], ...]
  def bk_tiles(tiles)
    boxes = tiles.map do |val, label, sub|
      "<div class='bkr-stat'><div class='val'>#{ERB::Util.html_escape(val)}</div><div class='lbl'>#{ERB::Util.html_escape(label)}</div>#{sub ? "<div class='sub'>#{sub}</div>" : ''}</div>"
    end
    "<div class='bkr-grid'>#{boxes.join}</div>".html_safe
  end

  # headers: ['Name', ['Paid', :r]]; rows: arrays of cell HTML (already escaped where needed)
  def bk_table(headers, rows, empty: 'Nothing to show yet.', total: nil)
    return "<p class='bkr-empty'>#{ERB::Util.html_escape(empty)}</p>".html_safe if rows.empty?

    head = headers.map { |h, cls| "<th class='#{cls}'>#{ERB::Util.html_escape(h)}</th>" }.join
    right = headers.map { |_, cls| cls }
    body = rows.map { |r| "<tr>#{r.each_with_index.map { |c, i| "<td class='#{right[i]}'>#{c}</td>" }.join}</tr>" }.join
    foot = total ? "<tr class='total'>#{total.each_with_index.map { |c, i| "<td class='#{right[i]}'>#{c}</td>" }.join}</tr>" : ''
    "<div class='bkr-wrap'><table class='bkr'><tr>#{head}</tr>#{body}#{foot}</table></div>".html_safe
  end

  def bk_h(title, csv_url = nil)
    "<div class='bkr-h'><h3>#{ERB::Util.html_escape(title)}</h3>#{csv_url ? "<a class='bkr-dl' href='#{csv_url}'>Download CSV</a>" : ''}</div>".html_safe
  end

  def bk_taka(amount)
    "৳#{number_with_delimiter(amount.to_i)}"
  end

  def bk_esc(text)
    ERB::Util.html_escape(text.to_s)
  end

  def bk_dhaka(time, format = '%d %b %Y')
    time ? time.in_time_zone('Asia/Dhaka').strftime(format) : '—'
  end
end
