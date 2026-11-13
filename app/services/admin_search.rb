# The search box in the admin top bar (Admin > Search). Looks for a word across members,
# profiles, payments, tickets, reports, listings, blogs and site pages, and also suggests
# admin pages by name ("revenue" -> the Revenue report). Read-only.
class AdminSearch
  BASE = '/shaheer10inara20'.freeze

  # Admin pages that can be found by name: [label, path, extra words]
  PAGES = [
    ['Dashboard', '', 'home overview'],
    ['Users', '/users', 'members accounts'],
    ['Marriage Profiles', '/marriage_profiles', 'profiles biodata'],
    ['Profile Reports', '/profile_reports', 'reported block safety'],
    ['Support Tickets', '/customer_supports', 'support help complaints'],
    ['Notifications', '/notifications', 'alerts'],
    ['BK+ Members', '/bk_plus_members', 'bk plus bk+ membership'],
    ['Assisted Services Sold', '/assisted_service_orders', 'verified follow up'],
    ['Revenue', '/revenue', 'money income sales payments'],
    ['Member Health', '/member_health', 'active inactive'],
    ['Kobul Activity', '/kobul_activity', 'kobul requests'],
    ['Matching Funnel', '/matching_funnel', 'matches'],
    ['Messages Sent', '/messages_sent', 'sms email log'],
    ['Safety', '/safety', 'reports blocks'],
    ['Orders', '/orders', 'payments transactions purchases'],
    ['Wedding Shopping Listings', '/market_places', 'market places vendors business advertise'],
    ['Wedding Shopping Categories', '/market_place_types', 'market place types'],
    ['About page', '/abouts', ''],
    ['Contact page', '/contacts', ''],
    ['FAQ', '/faqs', 'questions'],
    ['Terms of Use', '/terms_of_uses', 'terms conditions'],
    ['Privacy Policy', '/privacy_policies', 'privacy'],
    ['How It Works', '/process_flows', 'process steps'],
    ['Safety tips', '/precautionary_measures', 'precautions'],
    ['Blogs & Stories', '/blogs', 'success stories articles'],
    ['Ads', '/ads', 'advertisements banners'],
    ['Butterfly prices', '/configurations', 'butterflies settings price'],
    ['BK+ Plans', '/bk_plus_plans', 'bk plus bk+ prices'],
    ['Assisted Services', '/assisted_services', 'services'],
    ['Messages On / Off', '/messages_on_offs', 'sms email switches'],
    ['Support issue types', '/issue_types', ''],
    ['Admin users', '/admin_users', 'admins'],
    ['Permissions', '/permissions', 'roles']
  ].freeze

  Group = Struct.new(:title, :items, :total)
  Item = Struct.new(:title, :subtitle, :url)

  def initialize(query, limit: 5)
    @q = query.to_s.strip.first(80)
    @limit = limit
  end

  def blank?
    @q.length < 2
  end

  def groups
    return [] if blank?

    [pages, members, profiles, orders, tickets, reports, listings, blogs, site_texts].compact.select { |g| g.total.positive? }
  end

  private

  def like
    "%#{ActiveRecord::Base.sanitize_sql_like(@q)}%"
  end

  def digits
    @q.gsub(/\D/, '')
  end

  def group(title, scope, &block)
    total = scope.count
    Group.new(title, scope.limit(@limit).map(&block), total)
  rescue StandardError => e
    Rails.logger.error "[admin search] #{title}: #{e.message}"
    nil
  end

  def dhaka(time)
    time&.in_time_zone('Asia/Dhaka')&.strftime('%-d %b %Y')
  end

  def pages
    words = @q.downcase
    found = PAGES.select { |label, _, extra| "#{label} #{extra}".downcase.include?(words) }
    Group.new('Admin pages', found.first(@limit).map { |label, path, _| Item.new(label, 'Open this page', "#{BASE}#{path}") }, found.size)
  end

  def members
    scope = User.where('users.name ILIKE :q OR users.email ILIKE :q OR users.phone_number ILIKE :q', q: like)
    scope = scope.or(User.where('users.phone_number ILIKE ?', "%#{digits}%")) if digits.length >= 5
    group('Members', scope.order(created_at: :desc)) do |u|
      Item.new(u.name.presence || "Member ##{u.id}", [u.email, u.phone_number, "joined #{dhaka(u.created_at)}"].compact_blank.join(' · '), "#{BASE}/users/#{u.id}")
    end
  end

  def profiles
    scope = MarriageProfile.where('marriage_profiles.name ILIKE ?', like)
    scope = scope.or(MarriageProfile.where(id: digits.to_i)) if digits.present? && @q.match?(/\A\s*(bk)?\s*0*\d+\s*\z/i)
    group('Marriage Profiles', scope.order(created_at: :desc)) do |p|
      Item.new("#{p.unique_id} · #{p.name}", [p.gender&.titleize, p.verified ? 'Verified' : nil].compact.join(' · '), "#{BASE}/marriage_profiles/#{p.id}")
    end
  end

  def orders
    scope = Order.where('orders.customer_name ILIKE :q OR orders.customer_email ILIKE :q OR orders.customer_phone ILIKE :q OR orders.txn_no ILIKE :q', q: like)
    group('Orders', scope.order(created_at: :desc)) do |o|
      Item.new("#{o.customer_name.presence || 'Order'} · ৳#{o.total_amount.to_i}", "#{o.product.to_s.humanize} · #{o.status} · #{dhaka(o.created_at)}", "#{BASE}/orders/#{o.id}")
    end
  end

  def tickets
    scope = CustomerSupport.left_joins(:user)
                           .where('customer_supports.description ILIKE :q OR customer_supports.email ILIKE :q OR users.name ILIKE :q', q: like)
    group('Support Tickets', scope.order('customer_supports.created_at DESC')) do |t|
      Item.new(t.description.to_s.squish.truncate(70), "#{t.user&.name} · #{t.status.to_s.humanize} · #{dhaka(t.created_at)}", "#{BASE}/customer_supports/#{t.id}")
    end
  end

  def reports
    scope = ProfileReport.joins('LEFT JOIN marriage_profiles mp ON mp.id = profile_reports.reported_profile_id')
                         .where('profile_reports.details ILIKE :q OR profile_reports.admin_note ILIKE :q OR mp.name ILIKE :q', q: like)
    group('Profile Reports', scope.order('profile_reports.created_at DESC')) do |r|
      Item.new("#{r.reported_profile&.unique_id} · #{r.reason_label}", "#{r.status.to_s.humanize} · #{dhaka(r.created_at)}", "#{BASE}/profile_reports/#{r.id}")
    end
  end

  def listings
    scope = MarketPlace.where('market_places.name ILIKE :q OR market_places.contact_phone ILIKE :q OR market_places.contact_email ILIKE :q OR market_places.contact_name ILIKE :q', q: like)
    group('Wedding Shopping Listings', scope.order(created_at: :desc)) do |m|
      Item.new(m.name, [m.location, m.status].compact.join(' · '), "#{BASE}/market_places/#{m.id}")
    end
  end

  def blogs
    scope = Blog.where('blogs.title ILIKE :q OR blogs.author ILIKE :q OR blogs.partner ILIKE :q', q: like)
    group('Blogs & Stories', scope.order(created_at: :desc)) do |b|
      Item.new(b.title.presence || "Post ##{b.id}", "#{b.story_type.to_s.humanize} · #{b.status}", "#{BASE}/blogs/#{b.id}")
    end
  end

  # FAQ, Terms and Privacy sections whose title or text contain the word
  def site_texts
    rows = []
    [[Faq, 'FAQ', 'faqs'], [TermsOfUse, 'Terms of Use', 'terms_of_uses'], [PrivacyPolicy, 'Privacy Policy', 'privacy_policies']].each do |model, name, path|
      model.where('title ILIKE :q OR content ILIKE :q OR title_bn ILIKE :q OR content_bn ILIKE :q', q: like).order(:display_order).each do |r|
        rows << Item.new("#{name}: #{r.title.to_s.squish.truncate(60)}", 'Website page text', "#{BASE}/#{path}/#{r.id}")
      end
    end
    Group.new('Website pages', rows.first(@limit), rows.size)
  rescue StandardError => e
    Rails.logger.error "[admin search] site texts: #{e.message}"
    nil
  end
end
