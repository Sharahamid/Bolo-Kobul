# Assisted Services report: every paid Assisted Service (Get Verified, matchmaker, biodata
# help…), who bought it and when, so the team can follow up. Downloadable as CSV.
require 'csv'

ActiveAdmin.register_page 'Assisted Service Orders' do
  menu priority: 4, label: 'Assisted Services Sold'

  paid_orders = lambda do |service_id = nil|
    scope = Order.where(product: :assisted_service, status: :success)
                 .includes(:assisted_service, user: :marriage_profiles).order(created_at: :desc)
    service_id.present? ? scope.where(assisted_service_id: service_id) : scope
  end

  page_action :export, method: :get do
    orders = paid_orders.call(params[:service])
    csv = CSV.generate do |out|
      out << ['Date', 'Service', 'Profile ID(s)', 'Name', 'Phone', 'Email', 'Paid (Tk)', 'Transaction no.', 'Order no.']
      orders.each do |o|
        u = o.user
        out << [o.created_at.in_time_zone('Asia/Dhaka').strftime('%d %b %Y %I:%M %p'), o.assisted_service&.name,
                u&.marriage_profiles&.map(&:unique_id)&.join(', '), u&.name || o.customer_name,
                u&.phone_number || o.customer_phone, u&.email || o.customer_email, o.total_amount.to_i, o.txn_no, o.id]
      end
    end
    send_data csv, filename: "assisted_services_#{Date.current}.csv", type: 'text/csv'
  end

  content title: 'Assisted Services Sold' do
    orders = paid_orders.call(params[:service])
    all_paid = paid_orders.call
    month_start = Time.current.in_time_zone('Asia/Dhaka').beginning_of_month
    taka = ->(n) { "৳#{number_with_delimiter(n.to_i)}" }
    esc = ->(s) { ERB::Util.html_escape(s.to_s) }
    base = request.path
    per_service = all_paid.group_by(&:assisted_service)
    chips = ["<a href='#{base}' class='#{'on' if params[:service].blank?}'>All (#{all_paid.size})</a>"] +
            per_service.map { |svc, list| "<a href='#{base}?service=#{svc&.id}' class='#{'on' if params[:service].to_s == svc&.id.to_s}'>#{esc.call(svc&.name || 'Unknown')} (#{list.size})</a>" }

    rows = orders.map do |o|
      u = o.user
      ids = u&.marriage_profiles&.map(&:unique_id)&.join(', ')
      who = u ? "<a href='#{shaheer10inara20_user_path(u)}'>#{esc.call(ids.presence || "User ##{u.id}")}</a>" : '—'
      <<~ROW
        <tr>
          <td>#{o.created_at.in_time_zone('Asia/Dhaka').strftime('%d %b %Y, %I:%M %p')}</td>
          <td><b>#{esc.call(o.assisted_service&.name || 'Unknown')}</b></td>
          <td>#{who}</td>
          <td>#{esc.call(u&.name || o.customer_name)}</td>
          <td>#{esc.call(u&.phone_number || o.customer_phone)}</td>
          <td>#{esc.call(u&.email || o.customer_email)}</td>
          <td style="text-align:right">#{taka.call(o.total_amount)}</td>
          <td>#{esc.call(o.txn_no)}</td>
        </tr>
      ROW
    end.join

    text_node raw(<<~HTML)
      <style>
        .bk-as-grid { display:grid; grid-template-columns:repeat(3,1fr); gap:12px; margin-bottom:16px; }
        @media (max-width: 900px) { .bk-as-grid { grid-template-columns:1fr; } }
        .bk-as-stat { background:#fff; border:1px solid #e8e8e8; border-radius:8px; padding:16px; text-align:center; }
        .bk-as-stat .val { font-size:26px; font-weight:bold; color:#C98700; }
        .bk-as-stat .lbl { font-size:12px; color:#666; margin-top:4px; }
        .bk-as-chips { margin:0 0 12px; font-size:12px; display:flex; flex-wrap:wrap; gap:6px; align-items:center; }
        .bk-as-chips a { padding:4px 12px; border:1px solid #ddd; border-radius:999px; color:#412402; text-decoration:none; background:#fff; }
        .bk-as-chips a.on { background:#FFB627; border-color:#FFB627; font-weight:700; }
        .bk-as-chips a.dl { margin-left:auto; border-color:#FFB627; background:#FFF3CC; }
        .bk-as-wrap { overflow-x:auto; background:#fff; border:1px solid #e8e8e8; border-radius:8px; }
        table.bk-as { width:100%; border-collapse:collapse; font-size:13px; min-width:900px; }
        table.bk-as th { background:#FFF3CC; color:#412402; font-weight:700; text-align:left; padding:9px 10px; white-space:nowrap; border-bottom:1px solid #F1E2B5; }
        table.bk-as td { padding:8px 10px; border-bottom:1px solid #f2f2f2; white-space:nowrap; }
        .bk-as-empty { background:#fff; border:1px dashed #ddd; border-radius:8px; padding:14px; color:#888; font-size:13px; margin:0; }
      </style>
      <div class="bk-as-grid">
        <div class="bk-as-stat"><div class="val">#{all_paid.size}</div><div class="lbl">Assisted Services sold (all time)</div></div>
        <div class="bk-as-stat"><div class="val">#{taka.call(all_paid.select { |o| o.created_at >= month_start }.sum { |o| o.total_amount.to_d })}</div><div class="lbl">Sales this month</div></div>
        <div class="bk-as-stat"><div class="val">#{taka.call(all_paid.sum { |o| o.total_amount.to_d })}</div><div class="lbl">Sales all time</div></div>
      </div>
      <div class="bk-as-chips">Show: #{chips.join}<a class="dl" href="#{base}/export#{params[:service].present? ? "?service=#{params[:service].to_i}" : ''}">Download CSV</a></div>
      #{rows.empty? ? "<p class='bk-as-empty'>No Assisted Services sold yet.</p>" : "<div class='bk-as-wrap'><table class='bk-as'><tr><th>Date</th><th>Service</th><th>Profile ID(s)</th><th>Name</th><th>Phone</th><th>Email</th><th style='text-align:right'>Paid</th><th>Transaction no.</th></tr>#{rows}</table></div>"}
    HTML
  end
end
