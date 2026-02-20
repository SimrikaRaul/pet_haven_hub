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

# Background jobs
gem "sidekiq"

# Redis (for Sidekiq)
gem "redis"

# MessagePack for Rails cache
gem "msgpack", ">= 1.7.0"

# File uploads with ActiveStorage (no image processing on Windows to avoid vips/ffi issues)
# gem "image_processing", ">= 1.2"  # Disabled: causes ffi/vips issues on Windows
# gem "mini_magick", ">= 4.9.5"
# gem "ffi", ">= 1.15.0"

# File uploads (legacy - switching to ActiveStorage)
# gem "carrierwave"

# Geolocation
gem "geocoder"

# Grouping by date
gem "groupdate"

group :development, :test do
  gem "debug"
  gem "rspec-rails"
end

group :development do
  gem "web-console"
  gem "listen"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
end

# Windows timezone support
gem "tzinfo-data", platforms: %i[windows]
