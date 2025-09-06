source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.3'
gem 'activeadmin'
gem 'active_storage_validations'
gem 'bootsnap', '>= 1.4.2', require: false
gem 'bitmask_attributes'
gem 'carrierwave', '~> 2.0'
gem 'ckeditor'
gem 'cropper-rails'
gem 'devise', '~> 4.7.1'
gem 'exception_handler', '~> 0.8.0.0'
gem "figaro"
gem 'friendly_id', '~> 5.3'
gem 'has_friendship'
gem 'jbuilder', '~> 2.7'
gem "mini_magick"
gem 'omniauth-facebook', '~> 5.0'
gem 'omniauth-google-oauth2', '~> 0.8.0'
gem 'pg', '>= 0.18', '< 2.0'
gem 'puma', '~> 4.1'
gem 'rails', '~> 6.0.1'
gem 'redis', '~> 4.1', '>= 4.1.0'
gem 'sass-rails', '>= 6'
gem 'sidekiq', '~>5.2'
gem 'turbolinks', '~> 5'
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby] # Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'webpacker', '~> 4.0'
## Pagination Gem
gem 'will_paginate', '~> 3.1.0'
gem 'active_admin_role', '~> 0.2.2'
gem 'whenever', '~> 1.0.0', require: false

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'rspec-rails'
  gem 'rspec-expectations'
end

group :development do
  gem 'annotate'
  gem 'capistrano', require: false
  gem 'capistrano-rails', require: false
  gem 'capistrano-rvm', require: false
  gem 'capistrano3-puma', require: false
  gem 'capistrano-yarn', require: false
  gem 'capistrano-rails-console'
  gem 'capistrano-sidekiq'
  gem 'listen'
  gem 'pry', '~> 0.12.2'
  gem 'rubocop-rails', require: false
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'sshkit-interactive'
  gem 'web-console', '>= 3.3.0'
  gem 'slackistrano'
end

group :test do
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver'
  gem 'webdrivers'
end
