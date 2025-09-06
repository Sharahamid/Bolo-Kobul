require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Bolokobul
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0
    config.active_record.default_timezone = :local
    config.time_zone = 'Asia/Dhaka'
    config.active_record.time_zone_aware_attributes = false
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Exception Handler
    config.exception_handler = {
      email: ENV['EXCEPTION_EMAILS'],
      social: {
        facebook: "BoloKobulLtd"
      },
      # All keys interpolated as strings, so you can use symbols, strings or integers where necessary
      exceptions: {
        :all => {
          layout: nil
        },
        404 => {
          notification: false
        }
      }
    }
  end
end
