namespace :push do
  desc 'Create VAPID keys for phone notifications and add them to config/application.yml'
  task setup_keys: :environment do
    path = Rails.root.join('config', 'application.yml')
    contents = File.exist?(path) ? File.read(path) : ''
    if contents =~ /^VAPID_PRIVATE_KEY:/
      puts 'VAPID keys are already set in config/application.yml - nothing changed.'
      next
    end

    keys = WebPushService.generate_vapid_keys
    lines = []
    lines << '' unless contents.empty? || contents.end_with?("\n")
    lines << "VAPID_PUBLIC_KEY: '#{keys[:public_key]}'"
    lines << "VAPID_PRIVATE_KEY: '#{keys[:private_key]}'"
    lines << "VAPID_SUBJECT: 'mailto:support@bolokobul.com'" unless contents =~ /^VAPID_SUBJECT:/
    File.open(path, 'a') { |f| f.puts(lines.join("\n")) }
    puts 'VAPID keys added to config/application.yml. Restart the website to start using them.'
  end
end
