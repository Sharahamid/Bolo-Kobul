# One-off content update (14 Nov 2026): the FAQ says members can add "up to 5 photos";
# the site allows 4 (1 main photo + 3 more). Changes it in English and Bangla.
# Run on the server:  RAILS_ENV=production bundle exec rails runner script/faq_photo_count.rb
# Undo:               RAILS_ENV=production bundle exec rails runner script/faq_photo_count.rb undo
require 'json'

BACKUP = File.expand_path('~/faq_photo_count_backup.json')
SPACE = '(?:\s|&nbsp;|&#160;| )*'

EN = Regexp.new("up#{SPACE}to#{SPACE}(?:5|five)(#{SPACE})photos", Regexp::IGNORECASE)
# Bangla: ৫টি / ৫ টি / পাঁচটি ... ছবি  (with or without পর্যন্ত in between)
BN = Regexp.new("(?:৫|5|পাঁচ)(#{SPACE}টি)?(#{SPACE}পর্যন্ত)?(#{SPACE})ছবি")

if ARGV.first == 'undo'
  abort "No backup found at #{BACKUP}" unless File.exist?(BACKUP)
  JSON.parse(File.read(BACKUP)).each do |row|
    Faq.find(row['id']).update_columns(row['column'] => row['value'])
  end
  puts "Undone: FAQ restored from #{BACKUP}"
  exit
end
abort "Already done (backup exists at #{BACKUP}). Run with 'undo' first to repeat it." if File.exist?(BACKUP)

backup = []
count = 0
Faq.find_each do |faq|
  changes = {}
  en = faq.content.to_s
  if en.match?(EN)
    count += en.scan(EN).size
    changes[:content] = en.gsub(EN) { "up to 4#{Regexp.last_match(1)}photos" }
  end
  if faq.respond_to?(:content_bn)
    bn = faq.content_bn.to_s
    if bn.match?(BN)
      count += bn.scan(BN).size
      changes[:content_bn] = bn.gsub(BN) { "৪#{Regexp.last_match(1)}#{Regexp.last_match(2)}#{Regexp.last_match(3)}ছবি" }
    end
  end
  next if changes.empty?

  changes.each_key { |col| backup << { id: faq.id, column: col.to_s, value: faq[col] } }
  faq.update_columns(changes)
  puts "  ✓ FAQ ##{faq.id} (#{faq.title.to_s.squish.truncate(40)}): #{changes.keys.join(', ')}"
end

File.write(BACKUP, JSON.pretty_generate(backup))
puts count.zero? ? 'Nothing found to change.' : "Changed #{count} mention(s) to 4 photos. Backup: #{BACKUP}"
