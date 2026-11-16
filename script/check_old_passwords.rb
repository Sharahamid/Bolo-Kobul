# Were the old passwords (from the Misfit-era files) ever changed?
# For each one, paste the OLD value from the old file when asked. What you paste is not shown
# on screen, not saved and not printed: the script only says SAME (never changed - change it
# now) or DIFFERENT (already changed). Press Enter without pasting to skip one.
#
# Run on the server:  RAILS_ENV=production bundle exec rails runner script/check_old_passwords.rb
require 'io/console'

CHECKS = [
  ['SMS (Boom Cast) password',       -> { SECRETES.dig('sms', 'password') }],
  ['Payment (AamarPay) signature key', -> { SECRETES.dig('aamarpay', 'signature_key') }],
  ['Email (Mailgun) password',       -> { ENV['MAILGUN_PASSWORD'].presence || ENV['SMTP_PASSWORD'] }]
].freeze

def same?(a, b)
  return false if a.blank? || b.blank?

  ActiveSupport::SecurityUtils.secure_compare(a.to_s.strip, b.to_s.strip)
end

puts 'Paste each OLD value from the old file, then press Enter (nothing will show while you paste).'
puts 'Press Enter on its own to skip one.'
puts
results = CHECKS.map do |name, current|
  print "#{name} - old value: "
  old = STDIN.noecho(&:gets).to_s.chomp
  puts
  now = current.call
  verdict = if old.strip.empty? then 'skipped'
            elsif now.blank? then 'not set on the server (not in use?)'
            elsif same?(old, now) then 'SAME - never changed. Change it now.'
            else 'DIFFERENT - already changed. Nothing to do.'
            end
  [name, verdict]
end

puts
puts 'Result:'
results.each { |name, verdict| puts "  #{name}: #{verdict}" }
