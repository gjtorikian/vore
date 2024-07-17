# frozen_string_literal: true

if ENV.fetch("DEBUG", false)
  begin
    require "debug"
    require "amazing_print"
  rescue LoadError # rubocop:disable Lint/SuppressedException
  end
end

require "selma"

require_relative "vore/version"
require_relative "vore/configuration"
require_relative "vore/vore"
require_relative "vore/logger"
require_relative "vore/crawler"

module Vore
end
