# Short, plain SMS: short links (bolokobul.com/p/BK0000262) and only characters that keep
# an SMS at 160 per part. One emoji or a long dash makes the whole SMS "Unicode", where a
# part holds only 70 characters, so every text costs double.
module SmsText
  HOST = 'bolokobul.com'.freeze
  GSM = "@£$¥èéùìòÇ\nØø\rÅåΔ_ΦΓΛΩΠΨΣΘΞÆæßÉ !\"#¤%&'()*+,-./0123456789:;<=>?¡ABCDEFGHIJKLMNOPQRSTUVWXYZÄÖÑÜ§¿abcdefghijklmnopqrstuvwxyzäöñüà^{}\\[~]|€".freeze
  REPLACE = { '—' => '-', '–' => '-', '’' => "'", '‘' => "'", '“' => '"', '”' => '"', '…' => '...', '→' => '', '•' => '-' }.freeze

  module_function

  # bolokobul.com/p/BK0000262 – opens that member's profile (after login)
  def profile_link(profile)
    "#{HOST}/p/#{profile.unique_id}"
  end

  # bolokobul.com/c/BK0000262 – opens the chat with that member (after login)
  def chat_link(profile)
    "#{HOST}/c/#{profile.unique_id}"
  end

  # Only GSM characters: dashes and quotes made plain, emoji and other symbols dropped
  def plain(text)
    out = text.to_s.gsub(Regexp.union(REPLACE.keys), REPLACE)
    out.chars.select { |c| GSM.include?(c) }.join.gsub(/[ \t]{2,}/, ' ').strip
  end

  def unicode?(text)
    text.to_s.chars.any? { |c| !GSM.include?(c) }
  end

  # How many SMS parts the gateway will bill for this text
  def parts(text)
    len = text.to_s.length
    if unicode?(text)
      len <= 70 ? 1 : (len / 67.0).ceil
    else
      len <= 160 ? 1 : (len / 153.0).ceil
    end
  end

  # A website notification as one plain SMS: its words, then a short link to the page its
  # button opens (a profile or a chat), cut to fit one part
  def from_notification(content)
    html = content.to_s
    href = html[/href=['"]([^'"]+)['"]/, 1].to_s
    link = if (slug = href[%r{/marriage_profiles/([^/?#]+)/(?:profile_info|dashboard)}, 1]) && (p = MarriageProfile.find_by(slug: slug))
             profile_link(p)
           elsif (slug = href[%r{/messages/([^/?#]+)/profile}, 1]) && (p = MarriageProfile.find_by(slug: slug))
             chat_link(p)
           else
             HOST
           end
    words = plain(CGI.unescapeHTML(ActionController::Base.helpers.strip_tags(html)).squish)
    room = 160 - link.length - 2
    words = "#{words[0, room - 3].rstrip}..." if words.length > room
    words.match?(/[[:alnum:]]\z/) ? "#{words}: #{link}" : "#{words} #{link}"
  end
end
