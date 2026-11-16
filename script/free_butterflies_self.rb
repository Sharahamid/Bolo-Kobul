# One-off content update (16 Nov 2026): free butterflies are given only to profiles created
# for "Self" (see User#give_default_butterfly), so the FAQ, Terms and other pages say so
# instead of "new members get free butterflies".
# Run on the server:  RAILS_ENV=production bundle exec rails runner script/free_butterflies_self.rb
# Undo:               RAILS_ENV=production bundle exec rails runner script/free_butterflies_self.rb undo
require 'json'

BACKUP = File.expand_path('~/free_butterflies_self_backup.json')
GAP = '(?:\s|&nbsp;|&#160;| )+'
MODELS = [Faq, TermsOfUse, PrivacyPolicy, About, PrecautionaryMeasure, Contact].freeze

def words(text)
  Regexp.new(text.split(/\s+/).map { |w| Regexp.escape(w) }.join(GAP))
end

SELF_EN = 'members who register for themselves (Created for: Self)'
SELF_BN = 'নিজের জন্য প্রোফাইল খোলা সদস্যরা'
SELF_BN_OF = 'নিজের জন্য প্রোফাইল খোলা সদস্যদের'

# [column, old text, new text]
CHANGES = [
  [:content, 'New members get free butterflies', "Only #{SELF_EN} get free butterflies"],
  [:content, 'Each user gets 3 free butterflies', "Only #{SELF_EN} get free butterflies"],
  [:content, 'the free butterflies for new members', "the free butterflies for #{SELF_EN}"],
  [:content, 'the free butterflies given to new members', "the free butterflies given to #{SELF_EN}"],
  [:content, 'Since Bolo Kobul provides free butterflies to choose potential profiles',
   "Since Bolo Kobul gives free butterflies to #{SELF_EN} to choose potential profiles"],
  [:content_bn, 'নতুন সদস্যরা বিনামূল্যে বাটারফ্লাই পান', "শুধু #{SELF_BN} বিনামূল্যে বাটারফ্লাই পান"],
  [:content_bn, 'নতুন সদস্যরা কবুল পাঠানো ও গ্রহণের জন্য ফ্রি বাটারফ্লাই পান',
   "শুধু #{SELF_BN} কবুল পাঠানো ও গ্রহণের জন্য ফ্রি বাটারফ্লাই পান"],
  [:content_bn, 'নতুন সদস্যদের বিনামূল্যের বাটারফ্লাই', "#{SELF_BN_OF} বিনামূল্যের বাটারফ্লাই"],
  [:content_bn, 'নতুন সদস্যদের দেওয়া ফ্রি বাটারফ্লাই', "#{SELF_BN_OF} দেওয়া ফ্রি বাটারফ্লাই"]
].freeze

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
    CHANGES.each do |column, old_text, new_text|
      next unless row.has_attribute?(column)
      pattern = words(old_text)
      next unless row[column].to_s.match?(pattern)
      unless backup.any? { |b| b[:model] == model.name && b[:id] == row.id && b[:column] == column.to_s }
        backup << { model: model.name, id: row.id, column: column.to_s, value: row[column] }
      end
      row.update_columns(column => row[column].to_s.gsub(pattern, new_text))
      done << "#{model.name} ##{row.id} #{column}: \"#{old_text.truncate(45)}\""
    end
  end
end

File.write(BACKUP, JSON.pretty_generate(backup))
puts "Backup saved: #{BACKUP}"
puts "Changed (#{done.size}):"
done.each { |d| puts "  ✓ #{d}" }
puts '(Nothing needed changing.)' if done.empty?
