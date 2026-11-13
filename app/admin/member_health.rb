# Member health: how many members are active, and who needs a nudge (incomplete profile,
# no photo, not seen for 60+ days). Deactivated accounts are left out.
require 'csv'

ActiveAdmin.register_page 'Member Health' do
  menu parent: 'Reports', priority: 4, label: 'Member Health'

  lists = lambda do |name|
    profiles = MarriageProfile.joins(:user).where(users: { deactivated: [false, nil] }).includes(:user)
    case name.to_s
    when 'incomplete' then profiles.where('marriage_profiles.profile_completeness < ?', MarriageProfile::KOBUL_MIN_COMPLETENESS).order(:profile_completeness)
    when 'no_photo'   then profiles.where(profile_image: [nil, '']).order(created_at: :desc)
    else profiles.where('users.last_seen_at < :cut OR (users.last_seen_at IS NULL AND users.created_at < :cut)', cut: 60.days.ago).order('users.last_seen_at ASC NULLS FIRST')
    end
  end

  page_action :export, method: :get do
    name = %w[incomplete no_photo inactive].include?(params[:list]) ? params[:list] : 'inactive'
    csv = CSV.generate do |out|
      out << ['Profile ID', 'Name', 'Phone', 'Email', 'Profile complete (%)', 'Has photo', 'Joined', 'Last seen']
      lists.call(name).each do |p|
        u = p.user
        out << [p.unique_id, u.name, u.phone_number, u.email, p.profile_completeness.to_i, p.profile_image.present? ? 'Yes' : 'No',
                u.created_at&.in_time_zone('Asia/Dhaka')&.strftime('%d %b %Y'), u.last_seen_at&.in_time_zone('Asia/Dhaka')&.strftime('%d %b %Y') || 'Never']
      end
    end
    send_data csv, filename: "members_#{name}_#{Date.current}.csv", type: 'text/csv'
  end

  content title: 'Member Health' do
    users = User.where(deactivated: [false, nil])
    month_start = Time.current.in_time_zone('Asia/Dhaka').beginning_of_month
    base = request.path
    incomplete = lists.call(:incomplete)
    no_photo = lists.call(:no_photo)
    inactive = lists.call(:inactive)
    profiles_total = MarriageProfile.joins(:user).where(users: { deactivated: [false, nil] }).count

    table_rows = lambda do |scope|
      scope.limit(50).map do |p|
        u = p.user
        pct = p.profile_completeness.to_i
        ["<a href='#{shaheer10inara20_user_path(u)}'>#{bk_esc(p.unique_id)}</a>", bk_esc(u.name), bk_esc(u.phone_number),
         "<span class='#{pct < MarriageProfile::KOBUL_MIN_COMPLETENESS ? 'warn' : ''}'>#{pct}%</span>",
         p.profile_image.present? ? 'Yes' : "<span class='down'>No</span>", bk_dhaka(u.created_at), u.last_seen_at ? bk_dhaka(u.last_seen_at) : 'Never']
      end
    end
    headers = ['Profile ID', 'Name', 'Phone', 'Complete', 'Photo', 'Joined', 'Last seen']

    text_node bk_report_css
    text_node bk_tiles([
      [users.where('last_seen_at > ?', 7.days.ago).count, 'Active in the last 7 days', "of #{users.count} member accounts"],
      [users.where('last_seen_at > ?', 30.days.ago).count, 'Active in the last 30 days', nil],
      [users.where('created_at >= ?', month_start).count, 'Joined this month', "#{users.where('created_at >= ?', 30.days.ago).count} in the last 30 days"],
      [inactive.count, 'Not seen for 60+ days', 'Good people to win back']
    ])
    text_node bk_tiles([
      [profiles_total, 'Marriage profiles', nil],
      [incomplete.count, "Below #{MarriageProfile::KOBUL_MIN_COMPLETENESS}% complete", "They can't send Kobuls yet"],
      [no_photo.count, 'No profile photo', nil],
      [users.left_joins(:marriage_profiles).where(marriage_profiles: { id: nil }).count, 'Accounts with no profile', 'Signed up but never made a profile']
    ])
    text_node raw("<p class='bkr-note'>Deactivated accounts are not counted. Each list shows up to 50 members; Download CSV gives the full list (opens in Excel / Google Sheets).</p>")
    text_node bk_h("Profiles below #{MarriageProfile::KOBUL_MIN_COMPLETENESS}% complete (#{incomplete.count})", "#{base}/export?list=incomplete")
    text_node bk_table(headers, table_rows.call(incomplete), empty: 'Every profile is complete enough to send Kobuls.')
    text_node bk_h("Profiles with no photo (#{no_photo.count})", "#{base}/export?list=no_photo")
    text_node bk_table(headers, table_rows.call(no_photo), empty: 'Every profile has a photo.')
    text_node bk_h("Not seen for 60+ days (#{inactive.count})", "#{base}/export?list=inactive")
    text_node bk_table(headers, table_rows.call(inactive), empty: 'Everyone has visited in the last 60 days.')
  end
end
