# One-off content update (14 Nov 2026): About Us ("Why us" table) and Safety tips only
# claim what is true: every member is phone-verified, and profiles with a checked ID show
# a Verified badge (instead of "Thousands of verified profiles" / "Every single profile
# is screened").
# Run on the server:  RAILS_ENV=production bundle exec rails runner script/trust_claims_pages.rb
# Undo:               RAILS_ENV=production bundle exec rails runner script/trust_claims_pages.rb undo
require 'json'

BACKUP = File.expand_path('~/trust_claims_pages_backup.json')
GAP = '(?:\s|&nbsp;|&#160;| )+' # a space as the admin editor may have saved it

def words(text)
  Regexp.new(text.split(/\s+/).map { |w| Regexp.escape(w) }.join(GAP))
end

# [model, column, old text, new text]
CHANGES = [
  [About, :content, 'Screened profiles + Block feature',
   'Every member is phone-verified; profiles with a checked ID show a Verified badge'],
  [About, :content, 'Thousands of verified profiles', 'Members across Bangladesh and abroad'],
  [About, :content_bn, 'যাচাই করা প্রোফাইল + ব্লক সুবিধা',
   'প্রত্যেক সদস্যের ফোন নম্বর যাচাই করা; আইডি যাচাই হওয়া প্রোফাইলে ভেরিফায়েড ব্যাজ'],
  [About, :content_bn, 'হাজারো যাচাইকৃত প্রোফাইল', 'বাংলাদেশ ও প্রবাসের সদস্য'],
  [PrecautionaryMeasure, :content,
   'Every single profile is screened and inappropriate content and your matches are suggested as per your preferences.',
   'Every member is phone-verified, profiles with a checked ID show a Verified badge, and your matches are suggested as per your preferences.'],
  [PrecautionaryMeasure, :content_bn,
   'প্রতিটি প্রোফাইল ও অনুপযুক্ত বিষয়বস্তু যাচাই করা হয়, এবং আপনার পছন্দ অনুযায়ী ম্যাচ সুপারিশ করা হয়।',
   'প্রত্যেক সদস্যের ফোন নম্বর যাচাই করা হয়, আইডি যাচাই হওয়া প্রোফাইলে ভেরিফায়েড ব্যাজ থাকে, এবং আপনার পছন্দ অনুযায়ী ম্যাচ সুপারিশ করা হয়।']
].freeze

if ARGV.first == 'undo'
  abort "No backup found at #{BACKUP}" unless File.exist?(BACKUP)
  JSON.parse(File.read(BACKUP)).each do |row|
    row['model'].constantize.find(row['id']).update_columns(row['column'] => row['value'])
  end
  puts "Undone: pages restored from #{BACKUP}"
  exit
end

if File.exist?(BACKUP)
  abort "Already done (backup exists at #{BACKUP}). Run with 'undo' first to repeat it."
end

backup = []
done = []
missing = []
CHANGES.each do |model, column, old_text, new_text|
  pattern = words(old_text)
  rows = model.all.select { |r| r[column].to_s.match?(pattern) }
  if rows.empty?
    missing << "#{model.name} #{column}: \"#{old_text.truncate(50)}\""
    next
  end
  rows.each do |row|
    unless backup.any? { |b| b[:model] == model.name && b[:id] == row.id && b[:column] == column.to_s }
      backup << { model: model.name, id: row.id, column: column.to_s, value: row[column] }
    end
    row.update_columns(column => row[column].to_s.gsub(pattern, new_text))
    done << "#{model.name} ##{row.id} #{column}: \"#{old_text.truncate(40)}\""
  end
end

File.write(BACKUP, JSON.pretty_generate(backup))
puts "Backup saved: #{BACKUP}"
puts "Changed (#{done.size}):"
done.each { |d| puts "  ✓ #{d}" }
if missing.any?
  puts "Not found (already changed, or worded differently):"
  missing.each { |m| puts "  - #{m}" }
end
