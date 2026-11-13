# Safety: profile reports by reason, how quickly the team reviews them, deactivated
# accounts and blocked bot sign-ups.
ActiveAdmin.register_page 'Safety' do
  menu parent: 'Reports', priority: 8, label: 'Safety'

  content title: 'Safety' do
    reports = ProfileReport.all
    reviewed = reports.where.not(reviewed_at: nil)
    avg_hours = reviewed.any? ? (reviewed.sum { |r| r.reviewed_at - r.created_at } / reviewed.count / 3600.0) : nil
    avg_text = if avg_hours.nil? then '—'
               elsif avg_hours < 48 then "#{avg_hours.round} hours"
               else "#{(avg_hours / 24).round} days"
               end
    oldest_open = reports.unresolved.minimum(:created_at)
    late = reports.unresolved.where('created_at < ?', 24.hours.ago).count

    by_reason = ProfileReport::REASONS.map do |key, label|
      scope = reports.where(reason: key)
      total = scope.count
      next if total.zero?

      [bk_esc(label), total, scope.unresolved.count, scope.where(status: 'action_taken').count, scope.where(status: 'dismissed').count]
    end.compact
    serious = reports.unresolved.where(reason: %w[underage money harassment]).includes(:reported_profile, :reporter_profile).order(:created_at).map do |r|
      ["<a href='#{shaheer10inara20_profile_report_path(r)}'>##{r.id}</a>", "<span class='down'>#{bk_esc(r.reason_label)}</span>",
       bk_esc(r.reported_profile&.unique_id), bk_esc(r.reporter_profile&.unique_id), bk_dhaka(r.created_at, '%d %b %Y, %I:%M %p')]
    end

    deactivated = User.where(deactivated: true).includes(:marriage_profiles).order(updated_at: :desc).limit(20).map do |u|
      ["<a href='#{shaheer10inara20_user_path(u)}'>#{bk_esc(u.marriage_profiles.map(&:unique_id).join(', ').presence || "User ##{u.id}")}</a>",
       bk_esc(u.name), bk_esc(u.phone_number), bk_dhaka(u.updated_at)]
    end
    bots = BlockedRegistrationAttempt.where('created_at >= ?', 30.days.ago).group(:attempt_type).count
    bot_names = { 'honeypot' => 'Hidden bot trap', 'too_fast' => 'Form filled too fast', 'name_filter' => 'Suspicious name' }

    text_node bk_report_css
    text_node bk_tiles([
      [reports.unresolved.count, 'Reports waiting for review', oldest_open ? "Oldest from #{bk_dhaka(oldest_open)}" : 'All clear'],
      [late, 'Waiting more than 24 hours', late.positive? ? "<span class='down'>The FAQ promises review within 24 hours</span>" : 'On time'],
      [avg_text, 'Average time to review', "#{reviewed.count} reports reviewed"],
      [User.where(deactivated: true).count, 'Deactivated accounts', nil]
    ])
    text_node bk_h('Serious reports waiting (under 18, money or scam, harassment)')
    text_node bk_table(['Report', 'Reason', 'Reported', 'By', 'Reported at'], serious, empty: 'No serious reports waiting.')
    text_node bk_h('Reports by reason (all time)')
    text_node bk_table(['Reason', ['Total', 'r'], ['Waiting', 'r'], ['Action taken', 'r'], ['Dismissed', 'r']], by_reason, empty: 'No reports yet.')
    text_node bk_h('Bot sign-ups blocked in the last 30 days')
    text_node bk_table(['Blocked by', ['Attempts', 'r']], bots.map { |t, n| [bk_esc(bot_names[t] || t), n] }, empty: 'No blocked sign-ups in the last 30 days.')
    text_node bk_h('Recently deactivated accounts')
    text_node bk_table(['Profile ID(s)', 'Name', 'Phone', 'Last changed'], deactivated, empty: 'No deactivated accounts.')
    text_node raw("<p class='bkr-note'>Review time counts from when a report was made until it was marked Action taken or Dismissed (from 13 Nov 2026; older reports use their last change).</p>")
  end
end
