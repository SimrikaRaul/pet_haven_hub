source "https://rubygems.org"

ruby ">= 3.2.0"

# Rails 8
gem "rails", "~> 8.1.0"

# PostgreSQL
gem "pg", ">= 1.5"

# Web server
gem "puma", ">= 6.0"

# Asset pipeline
gem "sprockets-rails"

# Modern asset handling (Rails 8 uses importmap or jsbundling)
gem "importmap-rails"

# JSON builder
gem "jbuilder"

# Authentication
gem "devise"

# Pagination
gem "kaminari"

# Authorization
gem "pundit"

# HTTP client for Mailgun API
gem "httparty"

# Background jobs
gem "sidekiq"

# Redis (for Sidekiq)
gem "redis"

# MessagePack for Rails cache
gem "msgpack", ">= 1.7.0"
gem "groupdate"

group :development, :test do
  gem "debug"
  gem "rspec-rails"
  # Environment variable management
  gem "dotenv-rails"
end

group :development do
  gem "web-console"
  gem "listen"
  gem "letter_opener_web", "~> 3.0"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
end


gem "tzinfo-data", platforms: %i[windows]
