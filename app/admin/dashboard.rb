ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: proc { I18n.t("active_admin.dashboard") }

  content title: "Bolo Kobul — Admin Dashboard" do

    # ── Data queries ──────────────────────────────────────────────────────────
    total_users        = User.count
    new_today          = User.where(created_at: Date.today.all_day).count
    new_this_week      = User.where(created_at: 1.week.ago..Time.current).count
    new_this_month     = User.where(created_at: Date.today.beginning_of_month..Time.current).count
    new_this_year      = User.where(created_at: Date.today.beginning_of_year..Time.current).count

    kobul1_sent        = Friendship.count rescue 0
    kobul1_pending     = Friendship.pending.count rescue 0
    kobul1_accepted    = Friendship.accepted.count rescue 0
    kobul1_declined    = Friendship.declined.count rescue 0

    kobul2_total       = ChatFriendship.count rescue 0
    kobul2_pending     = ChatFriendship.pending.count rescue 0
    kobul2_accepted    = ChatFriendship.accepted.count rescue 0

    total_revenue      = Order.success.sum(:total_amount).to_f
    monthly_revenue    = Order.success.where(created_at: Date.today.beginning_of_month..Time.current).sum(:total_amount).to_f
    total_orders       = Order.success.count

    butterfly_orders      = Order.success.butterfly.count
    butterfly_qty         = Order.success.butterfly.sum(:quantity)
    butterfly_revenue     = Order.success.butterfly.sum(:total_amount).to_f
    assisted_orders       = Order.success.assisted_service.count
    assisted_revenue      = Order.success.assisted_service.sum(:total_amount).to_f
    butterfly_this_month  = Order.success.butterfly.where(created_at: Date.today.beginning_of_month..Time.current).sum(:quantity)
    assisted_this_month   = Order.success.assisted_service.where(created_at: Date.today.beginning_of_month..Time.current).count

    pending_profiles   = MarriageProfile.where(verified: [nil, false]).count rescue 0
    pending_blogs      = Blog.where(status: 'pending').count rescue 0
    open_tickets       = CustomerSupport.count rescue 0

    created_for_summary = User.group(:created_for).count
    
    months_data = 11.downto(0).map do |i|
      d = i.months.ago
      {
        month:       d.strftime("%b %y"),
        users:       User.where(created_at: d.beginning_of_month..d.end_of_month).count,
        revenue:     Order.success.where(created_at: d.beginning_of_month..d.end_of_month).sum(:total_amount).to_f.round(0),
        connections: (Friendship.where(status: 1, updated_at: d.beginning_of_month..d.end_of_month).count rescue 0),
        chats:       (ChatFriendship.where(status: 2, updated_at: d.beginning_of_month..d.end_of_month).count rescue 0)
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

    # ── Snapshot stats ────────────────────────────────────────────────────────
    text_node raw("<div class='bk-section-title' style='font-size:11px;font-weight:600;color:#888;text-transform:uppercase;letter-spacing:0.5px;margin-bottom:10px;'>Platform snapshot — today</div>")
    text_node raw(<<~HTML)
      <div class="bk-grid">
        <div class="bk-stat">
          <div class="val">#{number_with_delimiter(total_users)}</div>
          <div class="lbl">Total users</div>
          <div class="sub up">+#{new_today} today &nbsp;|&nbsp; +#{new_this_week} this week</div>
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
          <div class="lbl">Active chats (2nd Kobul)</div>
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
          <div class="lbl">2nd Kobul sent</div>
          <div class="sub">#{kobul2_pending} pending &nbsp;|&nbsp; #{kobul2_accepted} accepted</div>
        </div>
        <div class="bk-stat">
          <div class="val #{open_tickets > 0 ? 'down' : 'up'}">#{open_tickets}</div>
          <div class="lbl">Support tickets</div>
          <div class="sub">Total open tickets</div>
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
              <span>Profile approvals</span>
              <a href="/shefali007/marriage_profiles" class="bk-pill bk-pill-amber">#{pending_profiles} pending</a>
            </div>
            <div class="bk-action-row">
              <span>Support tickets</span>
              <a href="/shefali007/customer_supports" class="bk-pill bk-pill-red">#{open_tickets} open</a>
            </div>
            <div class="bk-action-row">
              <span>Blog approvals</span>
              <a href="/shefali007/blogs" class="bk-pill bk-pill-amber">#{pending_blogs} pending</a>
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
                fetch('/shefali007/send_admin_message', {
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
        column("Action") { |o| link_to "View", "/shefali007/orders/#{o.id}", class: "button" }
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
