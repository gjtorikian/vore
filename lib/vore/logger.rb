# frozen_string_literal: true

require "logger"
require "forwardable"

module Vore
  class << self
    attr_accessor :logger
  end

  class Logger
    class << self
      extend Forwardable
      delegate [:debug, :info, :warn, :error] => :instance

      attr_writer :instance

      def instance
        @instance ||= begin
          $stdout.sync = true
          instance = ::Logger.new($stdout)
          instance.level = ::Logger::DEBUG
          instance
        end
      end

      def level=(level)
        instance.level = level
      end
    end
  end
end

Vore.logger = Vore::Logger
