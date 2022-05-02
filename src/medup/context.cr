require "logger"

module Medup
  class Context
    property settings : ::Medup::Settings
    property logger : Logger

    def initialize(@settings = ::Medup::Settings.new, @logger = Logger.new(STDOUT))
    end
  end
end
