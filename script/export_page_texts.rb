# READ-ONLY: writes every website text that admin manages (FAQ, Terms of Use, Privacy
# Policy, How It Works, About, Safety tips, Contact) into one plain-text file, so it can be
# checked against how the site works today. Nothing is changed.
#
#   RAILS_ENV=production bundle exec rails runner script/export_page_texts.rb
require 'action_view'
include ActionView::Helpers::SanitizeHelper

PAGES = [
  ['FAQ', 'Faq'], ['TERMS OF USE', 'TermsOfUse'], ['PRIVACY POLICY', 'PrivacyPolicy'],
  ['HOW IT WORKS', 'ProcessFlow'], ['ABOUT', 'About'], ['SAFETY TIPS', 'PrecautionaryMeasure'],
  ['CONTACT', 'Contact']
].freeze
SKIP = %w[id created_at updated_at display_order].freeze

def plain(value)
  text = value.to_s.gsub(%r{<br\s*/?>|</p>|</li>|</h\d>|</tr>}i, "\n")
  CGI.unescapeHTML(strip_tags(text)).gsub(/[ \t]+/, ' ').gsub(/\n\s*\n+/, "\n").strip
end

path = File.expand_path("~/page_texts_#{Time.current.strftime('%Y%m%d_%H%M')}.txt")
File.open(path, 'w') do |out|
  PAGES.each do |heading, class_name|
    model = class_name.safe_constantize
    next unless model

    out.puts '=' * 70, heading, '=' * 70
    order = model.column_names.include?('display_order') ? [:display_order, :id] : [:id]
    model.order(*order).each do |row|
      out.puts "--- ##{row.id}#{" (order #{row.display_order})" if row.respond_to?(:display_order)}"
      row.attributes.each do |name, value|
        next if SKIP.include?(name) || value.blank? || !(value.is_a?(String))

        out.puts "[#{name}]", plain(value), ''
      end
    end
    out.puts
  end
end
puts "Saved: #{path} (#{File.size(path) / 1024} KB)"
