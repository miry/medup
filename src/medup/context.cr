require "logger"

module Medup
  class Context
    property settings : ::Medup::Settings
    property logger : Logger

    def initialize(@settings = ::Medup::Settings.new, @logger = Logger.new(STDOUT))
    end

    def platform_medium?
      settings.platform == ::Medup::Settings::PLATFORM_MEDIUM
    end

    def platform_devto?
      settings.platform == ::Medup::Settings::PLATFORM_DEVTO
    end
  end
end
