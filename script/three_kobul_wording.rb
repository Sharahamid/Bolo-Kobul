# One-off content update (16 Nov 2026): the "3 Kobul system" explained correctly on the
# About and Safety tips pages, in English and Bangla:
#   1st Kobul - getting to know each other (both see full profiles once it is accepted)
#   2nd Kobul - opens the chat
#   3rd Kobul - not on the site: the final "I do", when the two decide to marry
# The old text called the chat "Kobul 3" and a mutual match "Kobul 2".
# Run on the server:  RAILS_ENV=production bundle exec rails runner script/three_kobul_wording.rb
# Undo:               RAILS_ENV=production bundle exec rails runner script/three_kobul_wording.rb undo
require 'json'

BACKUP = File.expand_path('~/three_kobul_wording_backup.json')
MODELS = [About, PrecautionaryMeasure, Faq].freeze
S = '(?:\s|&nbsp;|&#160;| )+' # a space as the admin editor may have saved it
AMP = '(?:&|&amp;)'

# Matches the text however the editor saved spaces and quote marks
def words(text)
  text.split(/\s+/).map { |w| Regexp.escape(w) }.join(S)
      .gsub('"', '(?:"|&quot;|“|”)').gsub("'", "(?:'|&#39;|&#x27;|’)")
end

# [column, pattern, new text]
CHANGES = [
  # About us: English
  [:content, words('Kobul 1 (Show Interest)'), '1st Kobul (Getting to know)'],
  [:content, words(%q(Browse profiles and send a "Kobul" to someone you're interested in. This is your way of saying "I'm interested" without sharing personal contact details.)),
   "Send a 1st Kobul to someone you're interested in. If they accept, you can both see each other's full profiles, including education, family, lifestyle and preferences. No contact details are shared."],
  [:content, words('Kobul 2 (Mutual Match)'), '2nd Kobul (Start chatting)'],
  [:content, words('When both parties send a Kobul to each other, it becomes a mutual match. You can now view each other\'s full profile including detailed information about education, family, lifestyle, and preferences.'),
   'Like what you see? Send a 2nd Kobul. If they accept, a private chat opens so you can get to know each other safely on Bolo Kobul, at your own pace.'],
  [:content, "Kobul#{S}3#{S}\\(Connect#{S}#{AMP}#{S}Chat\\)", '3rd Kobul (The final "I do")'],
  [:content, words('Once mutually matched, unlock the ability to chat directly and take the conversation forward at your own pace, in a safe and private environment.'),
   'This one happens off the site. When the two of you like each other after chatting and decide to marry, you say the final Kobul: "I do"!'],
  # About us: Bangla
  [:content_bn, words('কবুল ১ (আগ্রহ প্রকাশ)'), '১ম কবুল (একে অপরকে জানা)'],
  [:content_bn, words('প্রোফাইল দেখুন এবং যার প্রতি আগ্রহী তাকে একটি "কবুল" পাঠান। ব্যক্তিগত যোগাযোগের তথ্য না দিয়েই "আমি আগ্রহী" বলার এটাই আপনার উপায়।'),
   'যার প্রতি আগ্রহী তাকে একটি ১ম কবুল পাঠান। তিনি গ্রহণ করলে আপনারা দুজনেই শিক্ষা, পরিবার, জীবনযাপন ও পছন্দসহ একে অপরের পূর্ণ প্রোফাইল দেখতে পারবেন। কোনো যোগাযোগের তথ্য শেয়ার করা হয় না।'],
  [:content_bn, words('কবুল ২ (পারস্পরিক মিল)'), '২য় কবুল (চ্যাট শুরু)'],
  [:content_bn, words('দুজনেই একে অপরকে কবুল পাঠালে সেটি পারস্পরিক মিল হয়। তখন শিক্ষা, পরিবার, জীবনযাপন ও পছন্দসহ একে অপরের পূর্ণ প্রোফাইল দেখতে পারবেন।'),
   'ভালো লাগলে একটি ২য় কবুল পাঠান। তিনি গ্রহণ করলে একটি গোপনীয় চ্যাট খুলে যাবে, আর বলো কবুলেই নিরাপদে, নিজের গতিতে একে অপরকে জানতে পারবেন।'],
  [:content_bn, words('কবুল ৩ (যোগাযোগ ও চ্যাট)'), '৩য় কবুল (চূড়ান্ত "কবুল")'],
  [:content_bn, words('পারস্পরিক মিল হলে সরাসরি চ্যাট চালু হয়, আর নিরাপদ ও গোপনীয় পরিবেশে নিজের গতিতে কথোপকথন এগিয়ে নিতে পারেন।'),
   'এটি সাইটের বাইরে ঘটে। চ্যাটের পর দুজন দুজনকে পছন্দ করে বিয়ের সিদ্ধান্ত নিলে আপনারা বলেন চূড়ান্ত কবুল: "কবুল"!'],
  # Safety tips
  [:content, words('You only unlock chat (3rd Kobul) after both parties have mutually expressed interest.'),
   'Chat only opens with a 2nd Kobul, after both of you have shown interest and accepted.'],
  [:content_bn, words('দুজনেই পারস্পরিকভাবে আগ্রহ জানানোর পরই কেবল চ্যাট (৩য় কবুল) চালু হয়।'),
   'দুজনেই আগ্রহ জানিয়ে গ্রহণ করার পরই কেবল ২য় কবুলের মাধ্যমে চ্যাট চালু হয়।']
].map { |col, pat, new_text| [col, Regexp.new(pat), new_text] }.freeze

# Old wording only (the new "3rd Kobul (The final "I do")" is not flagged)
LEFTOVER = /Kobul#{S}[123]\b|chat#{S}\(3rd#{S}Kobul\)|কবুল#{S}[১২৩]|চ্যাট#{S}\(৩য়#{S}কবুল\)/i

if ARGV.first == 'undo'
  abort "No backup found at #{BACKUP}" unless File.exist?(BACKUP)
  JSON.parse(File.read(BACKUP)).each do |row|
    row['model'].constantize.find(row['id']).update_columns(row['column'] => row['value'])
  end
  puts "Undone: pages restored from #{BACKUP}"
  exit
end
abort "Already done (backup exists at #{BACKUP}). Run with 'undo' first to repeat it." if File.exist?(BACKUP)

backup = []
done = []
MODELS.each do |model|
  model.all.each do |row|
    CHANGES.each do |column, pattern, new_text|
      next unless row.has_attribute?(column) && row[column].to_s.match?(pattern)

      unless backup.any? { |b| b[:model] == model.name && b[:id] == row.id && b[:column] == column.to_s }
        backup << { model: model.name, id: row.id, column: column.to_s, value: row[column] }
      end
      row.update_columns(column => row[column].to_s.gsub(pattern, new_text))
      done << "#{model.name} ##{row.id} #{column}: #{new_text.truncate(45)}"
    end
  end
end

File.write(BACKUP, JSON.pretty_generate(backup))
puts "Backup saved: #{BACKUP}"
puts "Changed (#{done.size}):"
done.each { |d| puts "  ✓ #{d}" }

puts "\nOld 'Kobul 1 / 2 / 3' wording still on these pages (send this to Claude if any):"
found = false
MODELS.each do |model|
  model.all.each do |row|
    %i[content content_bn].each do |column|
      next unless row.has_attribute?(column)

      row[column].to_s.scan(/.{0,60}#{LEFTOVER}.{0,60}/m).each do |hit|
        found = true
        puts "  - #{model.name} ##{row.id} #{column}: …#{ActionController::Base.helpers.strip_tags(hit).squish}…"
      end
    end
  end
end
puts '  (none)' unless found
