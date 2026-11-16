require 'cgi'

# Turns a designed (HTML) email into its plain-text copy. Gmail, Yahoo and other mail
# services trust emails that have both, so fewer land in spam. The text is made from the
# HTML automatically, so nothing has to be written twice. Used by ApplicationMailer#mail.
module EmailTextPart
  ENTITIES = { '&nbsp;' => ' ', '&middot;' => '·', '&mdash;' => '—', '&ndash;' => '–', '&rsquo;' => '’',
               '&lsquo;' => '‘', '&ldquo;' => '“', '&rdquo;' => '”', '&hellip;' => '…', '&copy;' => '©',
               '&rarr;' => '→', '&larr;' => '←', '&bull;' => '•' }.freeze

  module_function

  def to_text(html)
    s = html.to_s.dup
    s.gsub!(%r{<(head|style|script|title)[^>]*>.*?</\1>}mi, '')
    s.gsub!(/<!--.*?-->/m, '')
    # Links: "Button text (https://...)"; email addresses and repeated addresses stay short
    s.gsub!(%r{<a\b[^>]*href=["']([^"']+)["'][^>]*>(.*?)</a>}mi) do
      url = Regexp.last_match(1)
      label = Regexp.last_match(2).gsub(/<[^>]+>/, '').strip
      label = CGI.unescapeHTML(label)
      if url.start_with?('mailto:') || label.blank? || label == url || label == url.sub(%r{\Ahttps?://}, '')
        label.presence || url.sub('mailto:', '')
      else
        "#{label} (#{url})"
      end
    end
    s.gsub!(/<img\b[^>]*>/i, '')
    s.gsub!(/<li\b[^>]*>/i, "\n- ")
    s.gsub!(%r{<br\s*/?>}i, "\n")
    s.gsub!(%r{</(p|div|tr|table|h[1-6]|li|ul|ol)>}i, "\n")
    s.gsub!(%r{</td>}i, ' ')
    s.gsub!(/<[^>]+>/, '')
    s = CGI.unescapeHTML(s)
    ENTITIES.each { |entity, char| s = s.gsub(entity, char) }
    s = s.gsub("\u00A0", ' ')
    lines = s.lines.map { |l| l.gsub(/[ \t]+/, ' ').strip }
    lines.join("\n").gsub(/\n{3,}/, "\n\n").strip + "\n"
  end
end
