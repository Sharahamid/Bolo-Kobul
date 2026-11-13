# Assisted Services report: every paid Assisted Service (Get Verified, matchmaker, biodata
# help…), who bought it, and the team's follow-up (to do / in progress / done).
require 'csv'

ActiveAdmin.register_page 'Assisted Service Orders' do
  menu parent: 'Reports', priority: 2, label: 'Assisted Services Sold'

  paid_orders = lambda do |service_id = nil, follow = nil|
    scope = Order.where(product: :assisted_service, status: :success)
                 .includes(:assisted_service, user: :marriage_profiles).order(created_at: :desc)
    scope = scope.where(assisted_service_id: service_id) if service_id.present?
    scope = scope.where(fulfilment_status: follow) if Order::FULFILMENT_STATUSES.key?(follow.to_s)
    scope
  end

  page_action :export, method: :get do
    orders = paid_orders.call(params[:service], params[:follow])
    csv = CSV.generate do |out|
      out << ['Date', 'Service', 'Profile ID(s)', 'Name', 'Phone', 'Email', 'Paid (Tk)', 'Transaction no.', 'Order no.', 'Follow-up', 'Team note', 'Done on']
      orders.each do |o|
        u = o.user
        out << [o.created_at.in_time_zone('Asia/Dhaka').strftime('%d %b %Y %I:%M %p'), o.assisted_service&.name,
                u&.marriage_profiles&.map(&:unique_id)&.join(', '), u&.name || o.customer_name,
                u&.phone_number || o.customer_phone, u&.email || o.customer_email, o.total_amount.to_i, o.txn_no, o.id,
                Order::FULFILMENT_STATUSES[o.fulfilment_status], o.fulfilment_note,
                o.fulfilled_at&.in_time_zone('Asia/Dhaka')&.strftime('%d %b %Y')]
      end
    end
    send_data csv, filename: "assisted_services_#{Date.current}.csv", type: 'text/csv'
  end

  content title: 'Assisted Services Sold' do
    orders = paid_orders.call(params[:service], params[:follow])
    all_paid = paid_orders.call
    month_start = Time.current.in_time_zone('Asia/Dhaka').beginning_of_month
    base = request.path
    keep = ->(extra) { q = { service: params[:service].presence, follow: params[:follow].presence }.merge(extra).compact; q.empty? ? base : "#{base}?#{q.to_query}" }
    chip_cls = { 'to_do' => 'todo', 'in_progress' => 'prog', 'done' => 'done' }

    service_chips = ["<a href='#{keep.call(service: nil)}' class='#{'on' if params[:service].blank?}'>All services (#{all_paid.size})</a>"] +
                    all_paid.group_by(&:assisted_service).map { |svc, list| "<a href='#{keep.call(service: svc&.id)}' class='#{'on' if params[:service].to_s == svc&.id.to_s}'>#{bk_esc(svc&.name || 'Unknown')} (#{list.size})</a>" }
    follow_chips = ["<a href='#{keep.call(follow: nil)}' class='#{'on' if params[:follow].blank?}'>Any follow-up</a>"] +
                   Order::FULFILMENT_STATUSES.map { |k, label| "<a href='#{keep.call(follow: k)}' class='#{'on' if params[:follow] == k}'>#{label} (#{all_paid.count { |o| o.fulfilment_status == k }})</a>" }

    rows = orders.map do |o|
      u = o.user
      ids = u&.marriage_profiles&.map(&:unique_id)&.join(', ')
      who = u ? "<a href='#{shaheer10inara20_user_path(u)}'>#{bk_esc(ids.presence || "User ##{u.id}")}</a>" : '—'
      note = o.fulfilment_note.to_s.truncate(40)
      [bk_dhaka(o.created_at, '%d %b %Y, %I:%M %p'), "<b>#{bk_esc(o.assisted_service&.name || 'Unknown')}</b>", who,
       bk_esc(u&.name || o.customer_name), bk_esc(u&.phone_number || o.customer_phone), bk_taka(o.total_amount),
       "<span class='bkr-chip #{chip_cls[o.fulfilment_status]}'>#{Order::FULFILMENT_STATUSES[o.fulfilment_status]}</span>#{note.present? ? "<div style='font-size:11px;color:#888;margin-top:3px'>#{bk_esc(note)}</div>" : ''}",
       "<a href='#{edit_shaheer10inara20_order_path(o)}'>Update</a>"]
    end

    text_node bk_report_css
    text_node raw(<<~HTML)
      <style>
        .bk-as-chips { margin:0 0 10px; font-size:12px; display:flex; flex-wrap:wrap; gap:6px; align-items:center; }
        .bk-as-chips a { padding:4px 12px; border:1px solid #ddd; border-radius:999px; color:#412402; text-decoration:none; background:#fff; }
        .bk-as-chips a.on { background:#FFB627; border-color:#FFB627; font-weight:700; }
      </style>
    HTML
    text_node bk_tiles([
      [all_paid.count { |o| o.fulfilment_status == 'to_do' }, 'Waiting for follow-up', 'Paid, not started yet'],
      [all_paid.count { |o| o.fulfilment_status == 'in_progress' }, 'In progress', nil],
      [bk_taka(all_paid.select { |o| o.created_at >= month_start }.sum { |o| o.total_amount.to_d }), 'Sales this month', nil],
      [bk_taka(all_paid.sum { |o| o.total_amount.to_d }), 'Sales all time', "#{all_paid.size} services sold"]
    ])
    text_node raw("<div class='bk-as-chips'>Service: #{service_chips.join}</div><div class='bk-as-chips'>Follow-up: #{follow_chips.join}</div>")
    text_node bk_h('Paid Assisted Services', "#{base}/export?#{{ service: params[:service].presence, follow: params[:follow].presence }.compact.to_query}")
    text_node bk_table(['Date', 'Service', 'Profile ID(s)', 'Name', 'Phone', ['Paid', 'r'], 'Follow-up', ''], rows,
                       empty: 'No Assisted Services match this view.')
    text_node raw("<p class='bkr-note' style='margin-top:10px'>Click <b>Update</b> to set the follow-up (To do, In progress, Done) and add a note. New purchases start as To do.</p>")
  end
end
