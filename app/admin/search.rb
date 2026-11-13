# Search across the whole admin (the box in the top bar). Read-only.
#  - /shaheer10inara20/search?q=...          full results page, grouped
#  - /shaheer10inara20/search/suggest?q=...  suggestions shown while typing (JSON)
ActiveAdmin.register_page 'Search' do
  menu false

  page_action :suggest, method: :get do
    search = AdminSearch.new(params[:q], limit: 4)
    render json: {
      query: params[:q].to_s,
      groups: search.groups.map do |g|
        { title: g.title, total: g.total, items: g.items.map { |i| { title: i.title, subtitle: i.subtitle, url: i.url } } }
      end
    }
  end

  content title: proc { params[:q].present? ? "Search: #{params[:q].to_s.first(80)}" : 'Search' } do
    search = AdminSearch.new(params[:q], limit: 25)
    text_node bk_report_css
    text_node raw(<<~HTML)
      <form action="/shaheer10inara20/search" method="get" class="bk-search-big">
        <input type="search" name="q" value="#{ERB::Util.html_escape(params[:q])}" placeholder="Search members, profiles, payments, tickets, listings, pages…" autofocus>
        <button type="submit">Search</button>
      </form>
    HTML

    if search.blank?
      text_node raw("<p class='bkr-empty'>Type at least 2 letters or numbers.</p>")
    else
      groups = search.groups
      if groups.empty?
        text_node raw("<p class='bkr-empty'>Nothing found for “#{ERB::Util.html_escape(params[:q])}”. Try part of a name, an email, a phone number or a profile ID (for example BK1043).</p>")
      else
        summary = groups.map { |g| "<a href='#g-#{g.title.parameterize}'>#{ERB::Util.html_escape(g.title)} <b>#{g.total}</b></a>" }.join
        text_node raw("<div class='bk-search-summary'>Found in: #{summary}</div>")
        groups.each do |g|
          more = g.total > g.items.size ? " <span style='color:#999;font-weight:400'>(showing #{g.items.size} of #{g.total})</span>" : ''
          rows = g.items.map do |i|
            ["<a href='#{ERB::Util.html_escape(i.url)}'><b>#{ERB::Util.html_escape(i.title)}</b></a>", ERB::Util.html_escape(i.subtitle)]
          end
          text_node raw("<div class='bkr-h' id='g-#{g.title.parameterize}'><h3>#{ERB::Util.html_escape(g.title)} · #{g.total}#{more}</h3></div>")
          text_node bk_table(%w[Result Details], rows)
        end
      end
    end
  end
end
