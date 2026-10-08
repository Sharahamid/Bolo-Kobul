# /sitemap.xml: the public pages, so Google and other search engines find them all.
# Each page is listed in English with its Bangla version (?locale=bn) as an alternate.
class SitemapsController < ActionController::Base
  SITE = 'https://www.bolokobul.com'.freeze

  def show
    @pages = static_pages + blog_pages + assisted_service_pages
    expires_in 6.hours, public: true
    render formats: :xml
  end

  private

  def static_pages
    [['/', 'daily', '1.0'], ['/about', 'monthly', '0.6'], ['/how_it_works', 'monthly', '0.6'],
     ['/blogs', 'daily', '0.8'], ['/market_places', 'weekly', '0.5'], ['/faqs', 'monthly', '0.5'],
     ['/precautionary_measures', 'monthly', '0.4'], ['/contact', 'yearly', '0.4'],
     ['/terms_of_uses', 'yearly', '0.2'], ['/privacy_policies', 'yearly', '0.2']].map do |path, freq, priority|
      { path: path, changefreq: freq, priority: priority }
    end
  end

  def blog_pages
    Blog.approved.where.not(slug: [nil, '']).order(updated_at: :desc).limit(5000).map do |blog|
      { path: "/blogs/#{blog.slug}", lastmod: blog.updated_at, changefreq: 'monthly', priority: '0.7' }
    end
  end

  def assisted_service_pages
    AssistedService.order(:id).map do |service|
      { path: "/assisted_services/#{service.id}", lastmod: service.updated_at, changefreq: 'monthly', priority: '0.5' }
    end
  end
end
