# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))
require "vore"

require "minitest/autorun"
require "minitest/pride"

if ENV["CI"]
  require "vore/minitest_helper"

  require "webmock/minitest"
  WebMock.disable_net_connect!

  require "vcr"
  VCR.configure do |config|
    config.cassette_library_dir = "test/vcr_cassettes"
    config.hook_into(:webmock)
  end
end
