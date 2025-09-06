# Load the Rails application.
require_relative 'application'

# load yml data before running any initializer file
SECRETES = YAML.load(File.read(File.expand_path("#{Rails.root}/config/secrets.yml")))[Rails.env]

# Initialize the Rails application.
Rails.application.configure do
  config.time_zone = "Asia/Dhaka"
  config.active_record.default_timezone = :local
end
Rails.application.initialize!
