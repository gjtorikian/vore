# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in vore.gemspec
gemspec

gem "rake", "~> 13.0"

group :debug do
  gem "amazing_print"
  gem "debug"
end

group :test do
  gem "minitest", "~> 5.0"
  gem "minitest-focus", "~> 1.2"
  gem "vcr", "~> 6.2"
  gem "webmock", "3.25.1"
end

group :lint do
  gem "rubocop-standard"
end

gem "ruby-lsp", "~> 0.11", group: :development
