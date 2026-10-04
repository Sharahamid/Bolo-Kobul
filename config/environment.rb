# Load the Rails application.
require_relative 'application'

# load yml data before running any initializer file
SECRETES = YAML.load(File.read(File.expand_path("#{Rails.root}/config/secrets.yml")), aliases: true)[Rails.env]

# Rails 7.2+ no longer reads config/secrets.yml. Keep the same secret key as before (the
# order Rails 6 used: SECRET_KEY_BASE, then credentials, then secrets.yml), so members
# stay signed in and existing links keep working after the upgrade.
if ENV['SECRET_KEY_BASE'].blank? && Rails.application.credentials.secret_key_base.blank? &&
   SECRETES.is_a?(Hash) && SECRETES['secret_key_base'].present?
  Rails.application.config.secret_key_base = SECRETES['secret_key_base']
end

# Initialize the Rails application.
Rails.application.configure do
  config.time_zone = "Asia/Dhaka"
  config.active_record.default_timezone = :local
end
Rails.application.initialize!
