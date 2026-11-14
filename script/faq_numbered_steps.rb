# One-off fix (14 Nov 2026): in FAQ section 1, the answer "1. Create a free profile…
# 2. … 3. … 4. …" (and the Bangla "১. … ২. …") is shown as a numbered list, one step per
# line, instead of one long paragraph. Needs script/faq_sections_1_8.rb to have been run.
# Run on the server:  RAILS_ENV=production bundle exec rails runner script/faq_numbered_steps.rb
# Undo:               RAILS_ENV=production bundle exec rails runner script/faq_numbered_steps.rb undo
require 'json'

BACKUP = File.expand_path('~/faq_numbered_steps_backup.json')

# A paragraph whose text starts with "1. " / "১. " and has further numbered steps
PARA = %r{<p>\s*((?:1|১)\.\s.*?)</p>}m

def to_list(text)
  steps = text.split(/(?:\A|\s+)(?:\d+|[০-৯]+)\.\s+/).reject(&:blank?)
  return nil if steps.size < 2

  "<ol>\n#{steps.map { |s| "<li>#{s.strip}</li>" }.join("\n")}\n</ol>"
end

if ARGV.first == 'undo'
  abort "No backup found at #{BACKUP}" unless File.exist?(BACKUP)
  JSON.parse(File.read(BACKUP)).each do |row|
    Faq.find(row['id']).update_columns(content: row['content'], content_bn: row['content_bn'])
  end
  puts "Undone: restored from #{BACKUP}"
  exit
end
abort "Already done (backup exists at #{BACKUP}). Run with 'undo' first to repeat it." if File.exist?(BACKUP)

backup = []
Faq.find_each do |faq|
  changes = {}
  %i[content content_bn].each do |col|
    html = faq[col].to_s
    next unless html.match?(PARA)

    new_html = html.gsub(PARA) { to_list(Regexp.last_match(1)) || Regexp.last_match(0) }
    changes[col] = new_html if new_html != html
  end
  next if changes.empty?

  backup << { id: faq.id, content: faq.content, content_bn: faq.content_bn }
  faq.update_columns(changes)
  puts "  ✓ FAQ ##{faq.id} #{faq.title.to_s.squish}: #{changes.keys.join(', ')}"
end
File.write(BACKUP, JSON.pretty_generate(backup))
puts backup.empty? ? 'Nothing found to change.' : "Done. Backup: #{BACKUP}"
