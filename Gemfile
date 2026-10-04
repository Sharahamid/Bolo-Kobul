source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.4.6'
gem 'rails', '~> 8.1.4'

gem 'activeadmin', '~> 3.5'
gem 'active_admin_role', '~> 0.2.2'
gem 'active_storage_validations', '~> 3.0'
gem 'benchmark' # no longer built into Ruby 3.5; mini_magick needs it
gem 'bootsnap', require: false
gem 'bitmask_attributes', require: false # loaded in config/initializers/bitmask_attributes.rb
gem 'carrierwave', '~> 3.1'
gem 'ckeditor', '~> 4.3'
gem 'cropper-rails'
# Stylesheets are compiled with Dart Sass (the old libsass/sassc is no longer maintained)
gem 'dartsass-sprockets', '~> 3.2'
gem 'devise', '~> 4.9'
gem 'exception_handler', '~> 0.8.0'
gem 'figaro'
gem 'friendly_id', '~> 5.5'
gem 'has_friendship', '~> 1.2'
gem 'jbuilder', '~> 2.13'
gem 'mini_magick', '~> 4.10'
gem 'omniauth-facebook', '~> 10.0'
gem 'omniauth-google-oauth2', '~> 1.2'
gem 'omniauth-rails_csrf_protection', '~> 1.0'
gem 'pg', '~> 1.5'
gem 'puma', '~> 6.6'
gem 'redis', '~> 5.4'
gem 'sidekiq', '~> 7.3'
# connection_pool 3 changed an API that Sidekiq 7 still uses
gem 'connection_pool', '~> 2.5'
gem 'turbolinks', '~> 5'
gem 'twilio-ruby', '~> 7.10'
gem 'tzinfo-data', platforms: [:windows, :jruby] # Windows does not include zoneinfo files
gem 'webpacker', '~> 5.4'
gem 'whenever', '~> 1.0', require: false
gem 'will_paginate', '~> 4.0'

group :development, :test do
  gem 'debug', platforms: [:mri, :windows]
  gem 'rspec-rails'
end

group :development do
  gem 'listen'
  gem 'pry'
  gem 'rubocop-rails', require: false
  gem 'web-console'
end

group :test do
  gem 'capybara'
  gem 'selenium-webdriver'
end
