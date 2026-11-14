# One-off content update (14 Nov 2026) for every page text kept in admin (FAQ, Terms of
# Use, Privacy Policy, About Us, Safety Tips, Contact):
#  - one name everywhere: "BoloKobul.com" / "Bolokobul" / "BoloKobul" -> "Bolo Kobul"
#    (Bangla: "বলো কবুল"); web and email addresses (bolokobul.com) are not touched
#  - American spelling in the English texts (favourite -> favorite, organise -> organize…)
#  - Terms 12.1: the fixed "last revised" date is replaced by a pointer to the date that
#    the page now shows at the top automatically
# Best run AFTER the other 14 Nov page scripts. Safe to run more than once.
# Run on the server:  RAILS_ENV=production bundle exec rails runner script/brand_and_spelling.rb
# Undo:               RAILS_ENV=production bundle exec rails runner script/brand_and_spelling.rb undo
require 'json'
require Rails.root.join('lib/american_english').to_s

BACKUP = File.expand_path("~/brand_and_spelling_backup_#{Time.current.strftime('%Y%m%d_%H%M%S')}.json")

MODELS = {
  'Faq' => %w[title content],
  'TermsOfUse' => %w[title content],
  'PrivacyPolicy' => %w[title content],
  'About' => %w[content_type content],
  'PrecautionaryMeasure' => %w[title content],
  'Contact' => %w[heading content address]
}.freeze

def brand_en(text)
  text.gsub(%r{(?<![/@.\w])(?:BoloKobul\.com|BoloKobul|Bolokobul)(?![\w@])}, 'Bolo Kobul')
end

def brand_bn(text)
  text.gsub(/(?<![\/@.\w])BoloKobul\.com-এর/, 'বলো কবুলের')
      .gsub(/(?<![\/@.\w])BoloKobul\.com-এ/, 'বলো কবুলে')
      .gsub(/(?<![\/@.\w])BoloKobul\.com-কে/, 'বলো কবুলকে')
      .gsub(%r{(?<![/@.\w])(?:BoloKobul\.com|BoloKobul|Bolokobul)(?![\w@])}, 'বলো কবুল')
end

REVISED_EN = /These terms and conditions were last revised on [A-Za-z]+ \d{1,2}, \d{4}\./
REVISED_EN_NEW = 'The date at the top of this page shows when they were last revised.'
REVISED_BN = /এই শর্তাবলি সর্বশেষ সংশোধিত হয়েছে [^।]+।/
REVISED_BN_NEW = 'এই শর্তাবলি কবে সর্বশেষ সংশোধিত হয়েছে, তা এই পাতার ওপরে দেওয়া তারিখে দেখা যাবে।'

if ARGV.first == 'undo'
  file = Dir[File.expand_path('~/brand_and_spelling_backup_*.json')].max
  abort 'No backup found' unless file
  JSON.parse(File.read(file)).each do |row|
    row['model'].constantize.find(row['id']).update_columns(row['attrs'])
  end
  puts "Undone: restored from #{file}"
  exit
end

backup = []
counts = Hash.new(0)
MODELS.each do |model_name, cols|
  model = model_name.safe_constantize
  next unless model

  model.find_each do |row|
    changes = {}
    cols.each do |col|
      next unless row.has_attribute?(col)

      en = row[col].to_s
      new_en = AmericanEnglish.convert(brand_en(en))
      new_en = new_en.gsub(REVISED_EN, REVISED_EN_NEW) if model_name == 'TermsOfUse'
      changes[col] = new_en if new_en != en

      bn_col = "#{col}_bn"
      next unless row.has_attribute?(bn_col)

      bn = row[bn_col].to_s
      new_bn = brand_bn(bn)
      new_bn = new_bn.gsub(REVISED_BN, REVISED_BN_NEW) if model_name == 'TermsOfUse'
      changes[bn_col] = new_bn if new_bn != bn
    end
    next if changes.empty?

    backup << { 'model' => model_name, 'id' => row.id, 'attrs' => row.attributes.slice(*changes.keys) }
    row.update_columns(changes)
    counts[model_name] += 1
  end
end

File.write(BACKUP, JSON.pretty_generate(backup))
if counts.empty?
  puts 'Nothing to change: names and spellings are already consistent.'
else
  counts.each { |m, n| puts "  ✓ #{m}: #{n} section(s) updated" }
  puts "Backup: #{BACKUP}"
end
