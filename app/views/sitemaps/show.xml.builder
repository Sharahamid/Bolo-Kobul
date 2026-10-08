xml.instruct! :xml, version: '1.0', encoding: 'UTF-8'
xml.urlset xmlns: 'http://www.sitemaps.org/schemas/sitemap/0.9', 'xmlns:xhtml' => 'http://www.w3.org/1999/xhtml' do
  @pages.each do |page|
    english = "#{SitemapsController::SITE}#{page[:path]}"
    bangla = "#{english}#{page[:path].include?('?') ? '&' : '?'}locale=bn"
    xml.url do
      xml.loc english
      xml.lastmod page[:lastmod].to_date.iso8601 if page[:lastmod]
      xml.changefreq page[:changefreq]
      xml.priority page[:priority]
      xml.tag! 'xhtml:link', rel: 'alternate', hreflang: 'en', href: english
      xml.tag! 'xhtml:link', rel: 'alternate', hreflang: 'bn', href: bangla
    end
  end
end
