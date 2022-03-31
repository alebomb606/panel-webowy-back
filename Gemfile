source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.5'

gem 'api-pagination', '~> 4.8'
gem 'bootsnap',       '>= 1.1.0', require: false
gem 'carrierwave',    '~> 1.3.1'
gem 'carrierwave-base64', '~> 2.8'
gem 'devise',         '~> 4.5'
gem 'devise_token_auth', '~> 1.0.0'
gem 'dry-matcher',    '~> 0.7.0'
gem 'dry-monads',     '~> 1.2.0'
gem 'dry-struct',     '~> 0.6.0'
gem 'dry-validation', '~> 0.12.2'
gem 'fast_jsonapi',   '~> 1.5'
gem 'flag_shih_tzu',  '~> 0.3.23'
gem 'fog-aws',        '~> 3.4.0'
gem 'geocoder',       '~> 1.5.1'
gem 'gpx_ruby',       '~> 0.2.0'
gem 'haml',           '~> 5.0'
gem 'jsonapi-rails',  '~> 0.4.0'
gem 'kaminari',       '~> 1.1', git: 'https://github.com/kaminari/kaminari.git', branch: 'master', ref: 'd4db85e'
gem 'pg',             '~> 1.1'
gem 'phony',          '~> 2.15'
gem 'rack-cors',      '~> 1.0.2'
gem 'rails',          '~> 5.2.2'
gem 'redis',          '~> 4.0'
gem 'redis-namespace', '~> 1.6'
gem 'sassc-rails',    '~> 2.1'
gem 'sidekiq',        '~> 5.2.5'
gem 'sidekiq-cron',   '~> 1.1.0'
gem 'twilio-ruby',    '~> 5.21.2'
gem 'uglifier',       '~> 4.1'

group :development, :test do
  gem 'better_errors',    '~> 2.4.0'
  gem 'brakeman',         '~> 4.3'
  gem 'bullet',           '~> 5.9'
  gem 'bundle-audit',     '~> 0.1'
  gem 'byebug',           platforms: %i[mri mingw x64_mingw]
  gem 'faker',            git: 'https://github.com/stympy/faker.git', branch: 'master'
  gem 'haml_lint',        '~> 0.28.0'
  gem 'pry-rails',        '~> 0.3.7'
  gem 'recent_ruby',      '~> 0.1.1'
  gem 'rubocop',          '~> 0.62.0'
  gem 'simplecov',        '~> 0.16.1'
end

group :development do
  gem 'bcrypt_pbkdf'
  gem 'capistrano'
  gem 'capistrano-bundler'
  gem 'capistrano-rails'
  gem 'capistrano-rvm'
  gem 'ed25519'
  gem 'letter_opener'
  gem 'listen',      '>= 3.0.5', '< 3.2'
  gem 'puma',        '~> 4.3.12'
  gem 'web-console', '>= 3.3.0'
end

group :test do
  gem 'action-cable-testing', '~> 0.5.0'
  gem 'factory_bot_rails'
  gem 'fakeredis', require: 'fakeredis/rspec'
  gem 'rails-controller-testing'
  gem 'rspec-json_expectations'
  gem 'rspec-rails', '~> 3.8'
  gem 'rspec-sidekiq'
end

group :production do
  gem 'sentry-raven', '~> 2.9.0'
  gem 'unicorn', '~> 5.4'
end
