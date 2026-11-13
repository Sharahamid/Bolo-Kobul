# BK+ report: who has BK+ now, whose BK+ ends soon, who let it lapse, and BK+ sales.
# Each list can be downloaded as a CSV file (opens in Excel / Google Sheets).
require 'csv'

ActiveAdmin.register_page 'BK Plus Members' do
  menu priority: 3, label: 'BK+ Members'

  # rows for one list: :active, :expiring (next 7 days) or :expired (last 30 days)
  bk_rows = lambda do |list|
    now = Time.current
    users = case list.to_s
            when 'expiring' then User.where(bk_plus_until: now..(now + 7.days))
            when 'expired'  then User.where(bk_plus_until: (now - 30.days)...now)
            else User.where('bk_plus_until > ?', now)
            end
    users = users.includes(:marriage_profiles).order(:bk_plus_until).to_a
    orders = Order.where(user_id: users.map(&:id), product: :bk_plus, status: :success)
                  .includes(:bk_plus_plan).order(:created_at).group_by(&:user_id)
    users.map do |u|
      list_orders = orders[u.id] || []
      last = list_orders.last
      {
        user: u,
        profiles: u.marriage_profiles.map(&:unique_id).join(', '),
        plan: last&.bk_plus_plan&.label_en || (list_orders.empty? ? 'Given by admin' : '—'),
        first_bought: list_orders.first&.created_at,
        until_at: u.bk_plus_until,
        days_left: ((u.bk_plus_until - now) / 1.day).ceil,
        purchases: list_orders.size,
        paid: list_orders.sum { |o| o.total_amount.to_d }
      }
    end
  end

  page_action :export, method: :get do
    list = %w[active expiring expired].include?(params[:list]) ? params[:list] : 'active'
    rows = bk_rows.call(list)
    csv = CSV.generate do |out|
      out << ['Profile ID(s)', 'Name', 'Phone', 'Email', 'Latest plan', 'First bought', 'BK+ until', 'Days left', 'BK+ purchases', 'Total paid (Tk)']
      rows.each do |r|
        out << [r[:profiles], r[:user].name, r[:user].phone_number, r[:user].email, r[:plan],
                r[:first_bought]&.in_time_zone('Asia/Dhaka')&.strftime('%d %b %Y'),
                r[:until_at].in_time_zone('Asia/Dhaka').strftime('%d %b %Y'), r[:days_left], r[:purchases], r[:paid].to_i]
      end
    end
    send_data csv, filename: "bk_plus_#{list}_#{Date.current}.csv", type: 'text/csv'
  end

  content title: 'BK+ Members' do
    now = Time.current
    active = bk_rows.call(:active)
    expiring = bk_rows.call(:expiring)
    expired = bk_rows.call(:expired)
    sales = Order.where(product: :bk_plus, status: :success)
    month_start = now.in_time_zone('Asia/Dhaka').beginning_of_month
    renewers = sales.group(:user_id).having('COUNT(*) > 1').count.size
    by_plan = sales.joins(:bk_plus_plan).group('bk_plus_plans.days').sum(:total_amount)
    taka = ->(n) { "৳#{number_with_delimiter(n.to_i)}" }
    esc = ->(s) { ERB::Util.html_escape(s.to_s) }
    base = request.path

    table_for_rows = lambda do |rows, list, empty_text|
      return "<p class='bk-bp-empty'>#{empty_text}</p>" if rows.empty?

      body = rows.map do |r|
        u = r[:user]
        left = r[:days_left]
        left_html = if list == :expired then "<span class='down'>ended #{r[:until_at].in_time_zone('Asia/Dhaka').strftime('%d %b')}</span>"
                    elsif left <= 7 then "<span class='warn'>#{left} day#{'s' unless left == 1}</span>"
                    else "#{left} days"
                    end
        <<~ROW
          <tr>
            <td><a href="#{shaheer10inara20_user_path(u)}">#{esc.call(r[:profiles].presence || "User ##{u.id}")}</a></td>
            <td>#{esc.call(u.name)}</td>
            <td>#{esc.call(u.phone_number)}</td>
            <td>#{esc.call(r[:plan])}</td>
            <td>#{r[:until_at].in_time_zone('Asia/Dhaka').strftime('%d %b %Y')}</td>
            <td>#{left_html}</td>
            <td style="text-align:right">#{r[:purchases]}</td>
            <td style="text-align:right">#{taka.call(r[:paid])}</td>
          </tr>
        ROW
      end.join
      <<~TABLE
        <div class="bk-bp-wrap"><table class="bk-bp">
          <tr><th>Profile ID(s)</th><th>Name</th><th>Phone</th><th>Latest plan</th><th>BK+ until</th><th>Time left</th><th style="text-align:right">BK+ purchases</th><th style="text-align:right">Total paid</th></tr>
          #{body}
        </table></div>
      TABLE
    end

    recent = sales.includes(:user, :bk_plus_plan).order(created_at: :desc).limit(30).map do |o|
      ids = o.user&.marriage_profiles&.map(&:unique_id)&.join(', ')
      "<tr><td>#{o.created_at.in_time_zone('Asia/Dhaka').strftime('%d %b %Y, %I:%M %p')}</td><td>#{esc.call(ids.presence || '—')}</td><td>#{esc.call(o.user&.name)}</td><td>#{esc.call(o.bk_plus_plan&.label_en)}</td><td style='text-align:right'>#{taka.call(o.total_amount)}</td></tr>"
    end.join

    text_node raw(<<~HTML)
      <style>
        .bk-bp-grid { display:grid; grid-template-columns:repeat(4,1fr); gap:12px; margin-bottom:20px; }
        @media (max-width: 900px) { .bk-bp-grid { grid-template-columns:repeat(2,1fr); } }
        .bk-bp-stat { background:#fff; border:1px solid #e8e8e8; border-radius:8px; padding:16px; text-align:center; }
        .bk-bp-stat .val { font-size:26px; font-weight:bold; color:#C98700; }
        .bk-bp-stat .lbl { font-size:12px; color:#666; margin-top:4px; }
        .bk-bp-stat .sub { font-size:11px; margin-top:4px; color:#888; }
        .bk-bp-h { display:flex; justify-content:space-between; align-items:center; margin:22px 0 8px; gap:12px; flex-wrap:wrap; }
        .bk-bp-h h3 { margin:0; color:#412402; font-size:16px; }
        .bk-bp-dl { font-size:12px; padding:5px 12px; border:1px solid #FFB627; border-radius:999px; color:#412402; text-decoration:none; background:#FFF3CC; }
        .bk-bp-wrap { overflow-x:auto; background:#fff; border:1px solid #e8e8e8; border-radius:8px; }
        table.bk-bp { width:100%; border-collapse:collapse; font-size:13px; min-width:760px; }
        table.bk-bp th { background:#FFF3CC; color:#412402; font-weight:700; text-align:left; padding:9px 10px; white-space:nowrap; border-bottom:1px solid #F1E2B5; }
        table.bk-bp td { padding:8px 10px; border-bottom:1px solid #f2f2f2; white-space:nowrap; }
        .bk-bp-empty { background:#fff; border:1px dashed #ddd; border-radius:8px; padding:14px; color:#888; font-size:13px; margin:0; }
        .warn { color:#B45309; font-weight:700; } .down { color:#C0392B; font-weight:600; }
        .bk-bp-note { font-size:12px; color:#777; margin:0 0 14px; line-height:1.6; }
      </style>
      <div class="bk-bp-grid">
        <div class="bk-bp-stat"><div class="val">#{active.size}</div><div class="lbl">Active BK+ members</div><div class="sub">#{renewers} have bought BK+ more than once</div></div>
        <div class="bk-bp-stat"><div class="val">#{expiring.size}</div><div class="lbl">Ending in the next 7 days</div><div class="sub">Good people to remind</div></div>
        <div class="bk-bp-stat"><div class="val">#{expired.size}</div><div class="lbl">Ended in the last 30 days</div><div class="sub">Did not renew yet</div></div>
        <div class="bk-bp-stat"><div class="val">#{taka.call(sales.where('orders.created_at >= ?', month_start).sum(:total_amount))}</div><div class="lbl">BK+ sales this month</div><div class="sub">All time #{taka.call(sales.sum(:total_amount))} from #{sales.count} purchases</div></div>
      </div>
      <p class="bk-bp-note">
        Sales by plan (all time): #{by_plan.empty? ? 'none yet' : by_plan.sort.map { |days, amt| "#{days == 7 ? '1 week' : days.to_i.between?(28, 31) ? '1 month' : days == 365 ? '1 year' : "#{days} days"} #{taka.call(amt)}" }.join(' · ')}.
        "Given by admin" means BK+ was added by hand in Users, with no payment. Click a Profile ID to open the member.
      </p>

      <div class="bk-bp-h"><h3>Ending in the next 7 days (#{expiring.size})</h3><a class="bk-bp-dl" href="#{base}/export?list=expiring">Download CSV</a></div>
      #{table_for_rows.call(expiring, :expiring, 'No BK+ membership ends in the next 7 days.')}

      <div class="bk-bp-h"><h3>All active BK+ members (#{active.size})</h3><a class="bk-bp-dl" href="#{base}/export?list=active">Download CSV</a></div>
      #{table_for_rows.call(active, :active, 'No active BK+ members yet.')}

      <div class="bk-bp-h"><h3>Ended in the last 30 days (#{expired.size})</h3><a class="bk-bp-dl" href="#{base}/export?list=expired">Download CSV</a></div>
      #{table_for_rows.call(expired, :expired, 'No BK+ membership ended in the last 30 days.')}

      <div class="bk-bp-h"><h3>Latest BK+ purchases</h3></div>
      #{recent.empty? ? "<p class='bk-bp-empty'>No BK+ purchases yet.</p>" : "<div class='bk-bp-wrap'><table class='bk-bp'><tr><th>Date</th><th>Profile ID(s)</th><th>Name</th><th>Plan</th><th style='text-align:right'>Paid</th></tr>#{recent}</table></div>"}
    HTML
  end
end
