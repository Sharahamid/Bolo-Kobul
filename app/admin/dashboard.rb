ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: proc { I18n.t("active_admin.dashboard") }

  content title: "Bolo Kobul — Admin Dashboard" do

    # ── Data queries ──────────────────────────────────────────────────────────
    # Active members only (deactivated accounts are shown separately)
    active_users       = User.where(deactivated: [false, nil])
    total_users        = active_users.count
    deactivated_users  = User.where(deactivated: true).count
    new_today          = User.where(created_at: Date.current.all_day).count
    new_this_week      = User.where(created_at: 1.week.ago..Time.current).count
    new_this_month     = User.where(created_at: Date.current.beginning_of_month..Time.current).count
    new_this_year      = User.where(created_at: Date.current.beginning_of_year..Time.current).count

    kobul1_sent        = Friendship.count rescue 0
    kobul1_pending     = Friendship.pending.count rescue 0
    kobul1_accepted    = Friendship.accepted.count rescue 0
    kobul1_declined    = Friendship.declined.count rescue 0

    pair_key           = Arel.sql("LEAST(marriage_profile_id, chat_friend_id)::text || '-' || GREATEST(marriage_profile_id, chat_friend_id)::text")
    accepted_pairs     = (ChatFriendship.where(status: :accepted).distinct.pluck(pair_key) rescue [])
    waiting_pairs      = (ChatFriendship.where(status: [:pending, :requested]).distinct.pluck(pair_key) rescue []) - accepted_pairs
    kobul2_accepted    = accepted_pairs.size
    kobul2_pending     = waiting_pairs.size
    kobul2_total       = (ChatFriendship.distinct.count(pair_key) rescue 0)

    total_revenue      = Order.success.sum(:total_amount).to_f
    monthly_revenue    = Order.success.where(created_at: Date.current.beginning_of_month..Time.current).sum(:total_amount).to_f
    total_orders       = Order.success.count

    butterfly_orders      = Order.success.butterfly.count
    butterfly_qty         = Order.success.butterfly.sum(:quantity)
    butterfly_revenue     = Order.success.butterfly.sum(:total_amount).to_f
    assisted_orders       = Order.success.assisted_service.count
    assisted_revenue      = Order.success.assisted_service.sum(:total_amount).to_f
    bk_orders             = Order.success.bk_plus.count
    bk_revenue            = Order.success.bk_plus.sum(:total_amount).to_f
    bk_this_month         = Order.success.bk_plus.where(created_at: Date.current.beginning_of_month..Time.current).count
    bk_active             = User.where('bk_plus_until > ?', Time.current).count
    bk_ending_soon        = User.where(bk_plus_until: Time.current..7.days.from_now).count
    butterfly_this_month  = Order.success.butterfly.where(created_at: Date.current.beginning_of_month..Time.current).sum(:quantity)
    assisted_this_month   = Order.success.assisted_service.where(created_at: Date.current.beginning_of_month..Time.current).count

    # Members who paid for Get Verified and are still waiting (not every unverified profile)
    verify_service_ids = AssistedService.where('name ILIKE ?', '%verif%').pluck(:id)
    pending_profiles   = Order.success.assisted_service.where(assisted_service_id: verify_service_ids).where.not(fulfilment_status: 'done').count rescue 0
    pending_blogs      = Blog.where(status: 'pending').count rescue 0
    open_tickets       = CustomerSupport.where(status: [:in_queue, :processing]).count rescue 0

    # Needs attention today
    reports_waiting    = (ProfileReport.unresolved.count rescue 0)
    reports_late       = (ProfileReport.unresolved.where('created_at < ?', 24.hours.ago).count rescue 0)
    followups_todo     = (Order.success.assisted_service.where(fulfilment_status: 'to_do').count rescue 0)
    sms_failed_week    = (MessageLog.where(channel: 'sms_failed').where('created_at > ?', 7.days.ago).count rescue 0)
    active_7_days      = active_users.where('last_seen_at > ?', 7.days.ago).count
    last_month_range   = (Date.current.beginning_of_month - 1.month)..(Date.current.beginning_of_month - 1.day).end_of_day
    last_month_revenue = Order.success.where(created_at: last_month_range).sum(:total_amount).to_f

    created_for_summary = User.group(:created_for).count
    
    months_data = 11.downto(0).map do |i|
      d = i.months.ago
      {
        month:       d.strftime("%b %y"),
        users:       User.where(created_at: d.beginning_of_month..d.end_of_month).count,
        revenue:     Order.success.where(created_at: d.beginning_of_month..d.end_of_month).sum(:total_amount).to_f.round(0),
        connections: (Friendship.where(status: 1, updated_at: d.beginning_of_month..d.end_of_month).count rescue 0),
        chats:       (ChatFriendship.where(status: 2, updated_at: d.beginning_of_month..d.end_of_month).distinct.count(pair_key) rescue 0)
      }
    end

    # ── Styles ────────────────────────────────────────────────────────────────
    text_node raw(<<~HTML)
      <style>
        .bk-grid { display:grid; grid-template-columns:repeat(4,1fr); gap:12px; margin-bottom:20px; }
        .bk-stat { background:#fff; border:1px solid #e8e8e8; border-radius:6px; padding:16px; text-align:center; }
        .bk-stat .val { font-size:26px; font-weight:bold; color:#FFB627; }
        .bk-stat .lbl { font-size:12px; color:#888; margin-top:4px; }
        .bk-stat .sub { font-size:11px; margin-top:2px; }
        .up { color:#1D9E75; } .down { color:#E24B4A; }
        .bk-funnel-row { display:flex; align-items:center; padding:8px 0; border-bottom:1px solid #f0f0f0; font-size:13px; }
        .bk-funnel-row:last-child { border-bottom:none; }
        .bk-funnel-label { width:200px; color:#555; }
        .bk-funnel-bar-wrap { flex:1; background:#f0f0f0; border-radius:4px; height:8px; margin:0 12px; }
        .bk-funnel-bar { height:8px; border-radius:4px; background:#FFB627; }
        .bk-funnel-val { width:60px; text-align:right; font-weight:bold; }
        .bk-pill { padding:2px 10px; border-radius:12px; font-size:11px; text-decoration:none; }
        .bk-pill-amber { background:#FFF3CC; color:#856404; }
        .bk-pill-red { background:#FFE0E0; color:#c0392b; }
        .bk-pill-green { background:#D4EDDA; color:#155724; }
        .bk-pill-blue { background:#D0E8FF; color:#0c5460; }
        .bk-action-row { display:flex; justify-content:space-between; align-items:center; padding:8px 0; border-bottom:1px solid #f0f0f0; font-size:13px; }
        .bk-action-row:last-child { border-bottom:none; }
        .bk-chart-tabs { display:flex; gap:8px; margin-bottom:12px; flex-wrap:wrap; }
        .bk-chart-tab.active { background:#FFB627 !important; color:#fff !important; border-color:#FFB627; text-shadow:none !important; box-shadow:none !important; }
        .bk-chart-tab { padding:5px 14px; border:1px solid #ddd; border-radius:4px; cursor:pointer; font-size:12px; background:#fff; color:#333; font-weight:normal; text-transform:none; letter-spacing:normal; line-height:normal; text-shadow:none !important; box-shadow:none !important; }
        .bk-msg-form button { background:#FFB627 !important; color:#fff !important; border:none; padding:8px 20px; border-radius:4px; cursor:pointer; font-size:13px; font-weight:normal; text-transform:none; letter-spacing:normal; text-shadow:none !important; box-shadow:none !important; }
        .bk-msg-form input, .bk-msg-form textarea { width:100%; margin-bottom:8px; padding:8px; border:1px solid #ddd; border-radius:4px; font-size:13px; box-sizing:border-box; }
      </style>
    HTML

    # ── Needs attention today ─────────────────────────────────────────────────
    attention = [
      ['Profile reports waiting', reports_waiting, '/shaheer10inara20/profile_reports?q[status_in][]=open&q[status_in][]=reviewing', reports_late.positive? ? "#{reports_late} over 24 hours" : nil],
      ['Paid Assisted Services to do', followups_todo, '/shaheer10inara20/assisted_service_orders?follow=to_do', nil],
      ['Support tickets waiting', open_tickets, '/shaheer10inara20/customer_supports', nil],
      ['BK+ ending in 7 days', bk_ending_soon, '/shaheer10inara20/bk_plus_members', nil],
      ['SMS failed this week', sms_failed_week, '/shaheer10inara20/messages_sent', sms_failed_week.positive? ? 'Check Boom Cast balance' : nil],
      ['Blog posts / stories to approve', pending_blogs, '/shaheer10inara20/blogs', nil]
    ]
    attention_html = attention.map do |label, n, url, warn|
      cls = n.to_i.zero? ? 'bk-pill-green' : (warn ? 'bk-pill-red' : 'bk-pill-amber')
      "<a class='bk-att' href='#{url}'><span>#{label}#{warn ? "<br><small class='down'>#{warn}</small>" : ''}</span><span class='bk-pill #{cls}'>#{n.to_i.zero? ? 'All clear' : n}</span></a>"
    end.join
    rev_change = if last_month_revenue.zero? then ''
                 else d = ((monthly_revenue - last_month_revenue) * 100 / last_month_revenue).round; d >= 0 ? "<span class='up'>▲ #{d}%</span> vs last month" : "<span class='down'>▼ #{d.abs}%</span> vs last month"
                 end
    text_node raw(<<~HTML)
      <style>
        .bk-att-grid { display:grid; grid-template-columns:repeat(3,1fr); gap:10px; margin-bottom:20px; }
        @media (max-width: 900px) { .bk-att-grid { grid-template-columns:1fr; } }
        .bk-att { display:flex; justify-content:space-between; align-items:center; gap:10px; background:#fff; border:1px solid #e8e8e8; border-radius:6px; padding:12px 14px; font-size:13px; color:#333 !important; text-decoration:none !important; }
        .bk-att:hover { border-color:#FFB627; }
        .bk-att small { font-size:11px; }
      </style>
      <div style='font-size:11px;font-weight:600;color:#888;text-transform:uppercase;letter-spacing:0.5px;margin-bottom:10px;'>Needs attention today</div>
      <div class="bk-att-grid">#{attention_html}</div>
      <div class="bk-grid">
        <div class="bk-stat">
          <div class="val">#{number_with_delimiter(bk_active)}</div>
          <div class="lbl">Active BK+ members</div>
          <div class="sub">#{bk_ending_soon} ending in the next 7 days</div>
        </div>
        <div class="bk-stat">
          <div class="val">#{number_with_delimiter(active_7_days)}</div>
          <div class="lbl">Members active in the last 7 days</div>
          <div class="sub">of #{number_with_delimiter(total_users)} active accounts</div>
        </div>
        <div class="bk-stat">
          <div class="val">৳#{number_with_delimiter(monthly_revenue.to_i)}</div>
          <div class="lbl">Revenue this month</div>
          <div class="sub">#{rev_change.presence || "Last month ৳#{number_with_delimiter(last_month_revenue.to_i)}"}</div>
        </div>
        <div class="bk-stat">
          <div class="val">৳#{number_with_delimiter(last_month_revenue.to_i)}</div>
          <div class="lbl">Revenue last month</div>
          <div class="sub"><a href="/shaheer10inara20/revenue">See Revenue report</a></div>
        </div>
      </div>
    HTML

    # ── Snapshot stats ────────────────────────────────────────────────────────
    text_node raw("<div class='bk-section-title' style='font-size:11px;font-weight:600;color:#888;text-transform:uppercase;letter-spacing:0.5px;margin-bottom:10px;'>Platform snapshot — today</div>")
    text_node raw(<<~HTML)
      <div class="bk-grid">
        <div class="bk-stat">
          <div class="val">#{number_with_delimiter(total_users)}</div>
          <div class="lbl">Active member accounts</div>
          <div class="sub up">+#{new_today} today &nbsp;|&nbsp; +#{new_this_week} this week</div>
          <div class="sub" style="color:#999">#{deactivated_users} deactivated</div>
        </div>
        <div class="bk-stat">
          <div class="val">#{number_with_delimiter(kobul1_sent)}</div>
          <div class="lbl">Butterflies sent (1st Kobul)</div>
          <div class="sub">#{number_with_delimiter(kobul1_accepted)} accepted &nbsp;|&nbsp; #{number_with_delimiter(kobul1_declined)} declined</div>
        </div>
        <div class="bk-stat">
          <div class="val">#{number_with_delimiter(kobul1_accepted)}</div>
          <div class="lbl">1st Kobul connections</div>
          <div class="sub">#{number_with_delimiter(kobul1_pending)} still pending</div>
        </div>
        <div class="bk-stat">
          <div class="val">#{number_with_delimiter(kobul2_accepted)}</div>
          <div class="lbl">Open chats (pairs)</div>
          <div class="sub">#{number_with_delimiter(kobul2_pending)} pending &nbsp;|&nbsp; #{number_with_delimiter(kobul2_total)} total sent</div>
        </div>
        <div class="bk-stat">
          <div class="val">৳#{number_with_delimiter(total_revenue.to_i)}</div>
          <div class="lbl">Total revenue</div>
          <div class="sub up">৳#{number_with_delimiter(monthly_revenue.to_i)} this month</div>
        </div>
        <div class="bk-stat">
          <div class="val">#{number_with_delimiter(total_orders)}</div>
          <div class="lbl">Total orders</div>
          <div class="sub">Successful payments</div>
        </div>
        <div class="bk-stat">
          <div class="val">#{number_with_delimiter(kobul2_total)}</div>
          <div class="lbl">2nd Kobul pairs</div>
          <div class="sub">#{kobul2_pending} pending &nbsp;|&nbsp; #{kobul2_accepted} accepted</div>
        </div>
        <div class="bk-stat">
          <div class="val #{open_tickets > 0 ? 'down' : 'up'}">#{open_tickets}</div>
          <div class="lbl">Support tickets waiting</div>
          <div class="sub">In queue or being handled</div>
        </div>
      </div>
    HTML

    # ── Funnel + Pending actions ───────────────────────────────────────────────
    columns do
      column do
        panel "Sales Summary" do
          text_node raw(<<~HTML)
            <div style="margin-bottom:16px;">
              <div style="font-size:11px; font-weight:600; color:#888; text-transform:uppercase; letter-spacing:0.5px; margin-bottom:10px;">🦋 Butterflies</div>
              <div class="bk-action-row">
                <span>Total orders</span>
                <strong>#{number_with_delimiter(butterfly_orders)}</strong>
              </div>
              <div class="bk-action-row">
                <span>Total butterflies sold</span>
                <strong>#{number_with_delimiter(butterfly_qty)}</strong>
              </div>
              <div class="bk-action-row">
                <span>Sold this month</span>
                <strong>#{number_with_delimiter(butterfly_this_month)}</strong>
              </div>
              <div class="bk-action-row">
                <span>Revenue from butterflies</span>
                <strong>৳#{number_with_delimiter(butterfly_revenue.to_i)}</strong>
              </div>
            </div>
            <div style="border-top:1px solid #f0f0f0; padding-top:16px;">
              <div style="font-size:11px; font-weight:600; color:#888; text-transform:uppercase; letter-spacing:0.5px; margin-bottom:10px;">🤝 Assisted Services</div>
              <div class="bk-action-row">
                <span>Total orders</span>
                <strong>#{number_with_delimiter(assisted_orders)}</strong>
              </div>
              <div class="bk-action-row">
                <span>Orders this month</span>
                <strong>#{number_with_delimiter(assisted_this_month)}</strong>
              </div>
              <div class="bk-action-row">
                <span>Revenue from assisted services</span>
                <strong>৳#{number_with_delimiter(assisted_revenue.to_i)}</strong>
              </div>
            </div>
            <div style="border-top:1px solid #f0f0f0; padding-top:16px; margin-top:4px;">
              <div style="font-size:11px; font-weight:600; color:#888; text-transform:uppercase; letter-spacing:0.5px; margin-bottom:10px;">👑 BK+</div>
              <div class="bk-action-row"><span>Total purchases</span><strong>#{number_with_delimiter(bk_orders)}</strong></div>
              <div class="bk-action-row"><span>Purchases this month</span><strong>#{number_with_delimiter(bk_this_month)}</strong></div>
              <div class="bk-action-row"><span>Active members now</span><strong>#{number_with_delimiter(bk_active)}</strong></div>
              <div class="bk-action-row"><span>Revenue from BK+</span><strong>৳#{number_with_delimiter(bk_revenue.to_i)}</strong></div>
            </div>
            <div style="border-top:1px solid #f0f0f0; padding-top:16px; margin-top:4px;">
              <div style="font-size:11px; font-weight:600; color:#888; text-transform:uppercase; letter-spacing:0.5px; margin-bottom:10px;">💰 Combined</div>
              <div class="bk-action-row">
                <span>Total orders</span>
                <strong>#{number_with_delimiter(total_orders)}</strong>
              </div>
              <div class="bk-action-row">
                <span>Total revenue</span>
                <strong>৳#{number_with_delimiter(total_revenue.to_i)}</strong>
              </div>
              <div class="bk-action-row">
                <span>This month revenue</span>
                <strong>৳#{number_with_delimiter(monthly_revenue.to_i)}</strong>
              </div>
            </div>
          HTML
        end
      end

      column do
        panel "Pending Actions" do
          text_node raw(<<~HTML)
            <div class="bk-action-row">
              <span>Get Verified requests waiting</span>
              <a href="/shaheer10inara20/assisted_service_orders" class="bk-pill bk-pill-amber">#{pending_profiles} waiting</a>
            </div>
            <div class="bk-action-row">
              <span>Support tickets</span>
              <a href="/shaheer10inara20/customer_supports" class="bk-pill #{open_tickets.positive? ? 'bk-pill-red' : 'bk-pill-green'}">#{open_tickets} waiting</a>
            </div>
            <div class="bk-action-row">
              <span>Blog approvals</span>
              <a href="/shaheer10inara20/blogs" class="bk-pill bk-pill-amber">#{pending_blogs} pending</a>
            </div>
          HTML
        end

        panel "New Users" do
          text_node raw(<<~HTML)
            <div class="bk-action-row"><span>Today</span><strong>#{new_today}</strong></div>
            <div class="bk-action-row"><span>This week</span><strong>#{new_this_week}</strong></div>
            <div class="bk-action-row"><span>This month</span><strong>#{new_this_month}</strong></div>
            <div class="bk-action-row"><span>This year</span><strong>#{new_this_year}</strong></div>
            <div class="bk-action-row"><span>Till date</span><strong>#{number_with_delimiter(total_users)}</strong></div>
          HTML
        end

        panel "Send Message to User" do
          text_node raw(<<~HTML)
            <div class="bk-msg-form">
              <input type="text" id="bk-user-email" placeholder="User email address" />
              <textarea id="bk-msg-content" rows="3" placeholder="Type your message here..."></textarea>
              <button onclick="sendBkMessage()">Send Notification</button>
              <div id="bk-msg-status" style="margin-top:8px;font-size:12px;"></div>
            </div>
            <script>
              function sendBkMessage() {
                var email = document.getElementById('bk-user-email').value;
                var msg = document.getElementById('bk-msg-content').value;
                if (!email || !msg) { document.getElementById('bk-msg-status').innerHTML = '<span style="color:red">Please fill in both fields.</span>'; return; }
                fetch('/shaheer10inara20/send_admin_message', {
                  method: 'POST',
                  headers: { 'Content-Type': 'application/json', 'X-CSRF-Token': document.querySelector('meta[name=csrf-token]').content },
                  body: JSON.stringify({ email: email, message: msg })
                }).then(r => r.json()).then(data => {
                  document.getElementById('bk-msg-status').innerHTML = data.success
                    ? '<span style="color:green">Message sent successfully!</span>'
                    : '<span style="color:red">Error: ' + data.error + '</span>';
                }).catch(() => {
                  document.getElementById('bk-msg-status').innerHTML = '<span style="color:red">Failed to send.</span>';
                });
              }
            </script>
          HTML
        end
      end
    end

    # ── Monthly chart ─────────────────────────────────────────────────────────
    panel "Monthly Trends — Last 12 Months" do
      months_labels    = months_data.map { |d| d[:month] }.to_json
      users_series     = months_data.map { |d| d[:users] }.to_json
      revenue_series   = months_data.map { |d| d[:revenue] }.to_json
      connections_series = months_data.map { |d| d[:connections] }.to_json
      chats_series     = months_data.map { |d| d[:chats] }.to_json

      text_node raw(<<~HTML)
        <div class="bk-chart-tabs">
          <button class="bk-chart-tab active" onclick="switchBkChart('users', this)">Users registered</button>
          <button class="bk-chart-tab" onclick="switchBkChart('revenue', this)">Revenue (৳)</button>
          <button class="bk-chart-tab" onclick="switchBkChart('connections', this)">1st Kobul connections</button>
          <button class="bk-chart-tab" onclick="switchBkChart('chats', this)">Chats unlocked</button>
        </div>
        <canvas id="bkMainChart" height="70"></canvas>
        <script src="https://cdn.jsdelivr.net/npm/chart.js@3.9.1/dist/chart.min.js"></script>
        <script>
          var bkData = {
            labels: #{months_labels},
            users: #{users_series},
            revenue: #{revenue_series},
            connections: #{connections_series},
            chats: #{chats_series}
          };
          var bkChart = new Chart(document.getElementById('bkMainChart'), {
            type: 'bar',
            data: {
              labels: bkData.labels,
              datasets: [{
                label: 'Users registered',
                data: bkData.users,
                backgroundColor: 'rgba(255,182,39,0.7)',
                borderColor: '#FFB627',
                borderWidth: 1,
                borderRadius: 4
              }]
            },
            options: {
              responsive: true,
              plugins: { legend: { display: false } },
              scales: { y: { beginAtZero: true, ticks: { precision: 0 } } }
            }
          });
          function switchBkChart(type, btn) {
            document.querySelectorAll('.bk-chart-tab').forEach(b => b.classList.remove('active'));
            btn.classList.add('active');
            var labels = { users: 'Users registered', revenue: 'Revenue (৳)', connections: '1st Kobul connections', chats: 'Chats unlocked' };
            bkChart.data.datasets[0].data = bkData[type];
            bkChart.data.datasets[0].label = labels[type];
            bkChart.update();
          }
        </script>
      HTML
    end

    # ── Recent orders ─────────────────────────────────────────────────────────
    panel "Recent Orders" do
      table_for Order.success.order(created_at: :desc).limit(10) do
        column(:customer_email)
        column("Product") { |o| o.product.humanize }
        column(:quantity)
        column("Amount") { |o| "৳#{number_with_delimiter(o.total_amount.to_i)}" }
        column("Date") { |o| o.created_at.strftime("%d %b %Y %H:%M") }
        column("Action") { |o| link_to "View", "/shaheer10inara20/orders/#{o.id}", class: "button" }
      end
    end

    panel "User Registration — Created For Summary" do
      total = User.count.to_f
      text_node raw(<<~HTML)
        <table style="width:100%; border-collapse:collapse; font-size:13px;">
          <thead>
            <tr style="background:#f5f5f5;">
              <th style="padding:10px 12px; text-align:left; border-bottom:2px solid #ddd; color:#555;">Created For</th>
              <th style="padding:10px 12px; text-align:center; border-bottom:2px solid #ddd; color:#555;">Count</th>
              <th style="padding:10px 12px; text-align:left; border-bottom:2px solid #ddd; color:#555;">Breakdown</th>
              <th style="padding:10px 12px; text-align:right; border-bottom:2px solid #ddd; color:#555;">% of Total</th>
            </tr>
          </thead>
          <tbody>
            #{User.created_fors.keys.map do |key|
              count = created_for_summary[key] || 0
              pct = total > 0 ? ((count / total) * 100).round(1) : 0
              color = case key
                when 'self'               then ['#D4EDDA', '#155724']
                when 'parents'            then ['#D0E8FF', '#0c5460']
                when 'children'           then ['#D0E8FF', '#0c5460']
                when 'sibling'            then ['#FFF3CC', '#856404']
                when 'relative'           then ['#FFF3CC', '#856404']
                when 'friend'             then ['#FFE0B2', '#7c4d00']
                when 'colleague'          then ['#FFE0B2', '#7c4d00']
                when 'other_as_matchmaker' then ['#F8D7DA', '#721c24']
                else ['#f0f0f0', '#555']
                end
              <<~ROW
                <tr style="border-bottom:1px solid #eee;">
                  <td style="padding:10px 12px;">
                    <span style="background:#{color[0]}; color:#{color[1]}; padding:2px 10px; border-radius:10px; font-size:11px; font-weight:600;">#{key.titleize}</span>
                  </td>
                  <td style="padding:10px 12px; text-align:center; font-weight:bold;">#{number_with_delimiter(count)}</td>
                  <td style="padding:10px 12px;">
                    <div style="background:#f0f0f0; border-radius:4px; height:8px; width:100%;">
                      <div style="background:#{color[0]}; border:1px solid #{color[1]}; height:8px; border-radius:4px; width:#{[pct, 100].min}%;"></div>
                    </div>
                  </td>
                  <td style="padding:10px 12px; text-align:right; color:#888;">#{pct}%</td>
                </tr>
              ROW
            end.join}
            <tr style="background:#f9f9f9; font-weight:bold;">
              <td style="padding:10px 12px;">Total</td>
              <td style="padding:10px 12px; text-align:center;">#{number_with_delimiter(total.to_i)}</td>
              <td style="padding:10px 12px;"></td>
              <td style="padding:10px 12px; text-align:right;">100%</td>
            </tr>
          </tbody>
        </table>
      HTML
    end
  end
end
