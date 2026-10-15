# Tells search engines which address is the real one for each page, so the same page
# reached in different ways (bolokobul.com or www, a blog by number or by name, extra
# ?source=... links) is counted once. Bangla pages (?locale=bn) are their own page,
# linked to the English one as its translation.
module SeoHelper
  SITE = 'https://www.bolokobul.com'.freeze
  # The only query values that change what a public page shows
  KEPT_PARAMS = %w[page].freeze

  def canonical_url(locale = I18n.locale)
    path = canonical_path
    query = request.query_parameters.slice(*KEPT_PARAMS).reject { |_, v| v.blank? || v.to_s == '1' }
    query['locale'] = 'bn' if locale.to_s == 'bn'
    query.any? ? "#{SITE}#{path}?#{query.to_query}" : "#{SITE}#{path}"
  end

  private

  def canonical_path
    blog = @blog if controller_name == 'blogs' && action_name == 'show'
    return "/blogs/#{blog.slug}" if blog.respond_to?(:slug) && blog.slug.present?

    path = request.path.chomp('/')
    path.empty? ? '/' : path
  end
end
