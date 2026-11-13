# Matching funnel: how far members get, from making a profile to an open chat and marriage.
# Kobul steps come from the notifications each step creates (declined or cancelled Kobuls
# are removed from the Kobul tables), so members who deleted their account drop out.
ActiveAdmin.register_page 'Matching Funnel' do
  menu parent: 'Reports', priority: 6, label: 'Matching Funnel'

  content title: 'Matching Funnel' do
    days = params[:days].to_i
    since = days.positive? ? days.days.ago : nil
    within = ->(scope, col = 'created_at') { since ? scope.where("#{scope.table_name}.#{col} >= ?", since) : scope }
    recipients = ->(pattern) { within.call(Notification.where('content LIKE ?', pattern)).distinct.count(:recipient_id) }
    users_of_profiles = ->(profile_ids) { MarriageProfile.where(id: profile_ids).distinct.count(:user_id) }

    steps = [
      ['Made a marriage profile', within.call(MarriageProfile).distinct.count(:user_id),
       'Members (accounts) with at least one profile.'],
      ["Profile at least #{MarriageProfile::KOBUL_MIN_COMPLETENESS}% complete", within.call(MarriageProfile.where('profile_completeness >= ?', MarriageProfile::KOBUL_MIN_COMPLETENESS)).distinct.count(:user_id),
       'Complete enough to send Kobuls.'],
      ['Received a 1st Kobul', recipients.call('A butterfly has fluttered your way!%'),
       'Someone showed interest in them.'],
      ['Had a 1st Kobul accepted', recipients.call('Good news! % has accepted your 1st Kobul!%'),
       'They sent a 1st Kobul and the other person said yes (photos and details opened).'],
      ['Received a 2nd Kobul', recipients.call('% would like to chat with you.%'),
       'Someone asked to chat with them.'],
      ['Had a 2nd Kobul accepted (chat opened)', recipients.call('% has accepted your 2nd Kobul.%'),
       'Private chat opened.'],
      ['Sent at least one chat message', users_of_profiles.call(within.call(Message).distinct.select(:sender_id)),
       'Actually started talking.']
    ]
    top = [steps.first[1], 1].max
    rows = steps.each_with_index.map do |(label, n, help), i|
      prev = i.zero? ? nil : steps[i - 1][1]
      step_rate = prev.nil? ? '—' : (prev.zero? ? '—' : "#{(n * 100.0 / prev).round}%")
      ["<b>#{i + 1}. #{bk_esc(label)}</b><div style='font-size:11px;color:#888'>#{bk_esc(help)}</div>",
       "#{n}<span class='bkr-bar' style='width:#{(n * 160.0 / top).round}px'></span>",
       step_rate, "#{(n * 100.0 / top).round}%"]
    end
    stories = Blog.where(story_type: 'success_story', status: 'approved')
    stories = stories.where('created_at >= ?', since) if since

    text_node bk_report_css
    text_node raw("<p class='bkr-note'>Each step counts members, not Kobuls. <b>From the step before</b> shows how many moved on from the previous step; <b>of all</b> compares with everyone who made a profile. Show: #{[[0, 'All time'], [90, 'Last 90 days'], [30, 'Last 30 days']].map { |d, l| "<a href='?days=#{d}'#{' style="font-weight:700"' if d == days}>#{l}</a>" }.join(' · ')}</p>")
    text_node bk_table(['Step', 'Members', ['From the step before', 'r'], ['Of all', 'r']], rows)
    text_node bk_tiles([
      [stories.count, 'Success stories published', 'Couples who shared their story'],
      [ChatFriendship.where(status: :accepted).distinct.count(Arel.sql("LEAST(marriage_profile_id, chat_friend_id)::text || '-' || GREATEST(marriage_profile_id, chat_friend_id)::text")), 'Chats open right now', 'Pairs who can message each other'],
      [within.call(Message).count, 'Chat messages sent', nil],
      ['127', 'Marriages arranged by the founder', 'Online and offline, as of Nov 2026']
    ])
    text_node raw("<p class='bkr-note'>The site does not ask members whether they got married, so marriages are not counted automatically. Members who deleted their account are not included.</p>")
  end
end
