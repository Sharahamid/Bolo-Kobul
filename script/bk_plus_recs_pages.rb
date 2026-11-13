# One-off content update (14 Nov 2026): adds the new BK+ perk (20 recommendations a day
# instead of 10) to Terms 3.7 and the BK+ FAQ, in English and Bangla.
# Run on the server:  RAILS_ENV=production bundle exec rails runner script/bk_plus_recs_pages.rb
# Undo:               RAILS_ENV=production bundle exec rails runner script/bk_plus_recs_pages.rb undo
require 'json'

BACKUP = File.expand_path('~/bk_plus_recs_pages_backup.json')
terms = TermsOfUse.where('title LIKE ?', '3.7%BK+%').first
faq = Faq.where('title LIKE ?', '%BK+%').first
abort 'Could not find Terms 3.7 BK+ or the BK+ FAQ - nothing changed.' unless terms && faq

if ARGV.first == 'undo'
  abort "No backup found at #{BACKUP}" unless File.exist?(BACKUP)
  JSON.parse(File.read(BACKUP)).each do |r|
    rec = r['model'].constantize.find(r['id'])
    rec.update_columns(content: r['content'], content_bn: r['content_bn'])
    puts "Restored #{r['model']} #{rec.id}"
  end
  exit
end

abort 'Already added - nothing changed.' if terms.content.include?('20 recommended matches')

File.write(BACKUP, JSON.pretty_generate([terms, faq].map { |r| { 'model' => r.class.name, 'id' => r.id, 'content' => r.content, 'content_bn' => r.content_bn } }))
puts "Backup saved: #{BACKUP}"

report = []
step = ->(rec, field, find, insert_before) {
  text = rec.send(field).to_s
  ok = text.include?(find)
  rec.send("#{field}=", text.sub(find, insert_before + find)) if ok
  report << "#{ok ? 'DONE' : 'SKIP (text not found)'} #{rec.class.name} #{rec.id} #{field}"
}

ActiveRecord::Base.transaction do
  step.(terms, :content, '<li>bonus butterflies', "<li>up to 20 recommended matches a day instead of 10;</li>\n")
  step.(terms, :content_bn, '<li>বোনাস বাটারফ্লাই', "<li>প্রতিদিন ১০টির বদলে সর্বোচ্চ ২০টি রেকমেন্ডেড ম্যাচ;</li>\n")
  step.(faq, :content, '; and bonus butterflies', '; up to 20 recommendations a day instead of 10')
  step.(faq, :content_bn, '; আর প্রতিবার', '; প্রতিদিন ১০টির বদলে সর্বোচ্চ ২০টি রেকমেন্ডেশন')
  terms.save!
  faq.save!
end
puts report
