require "option_parser"

module Medup
  class Command
    def self.run
      token = ENV.fetch("MEDIUM_TOKEN", "")
      user = nil
      exit = false

      OptionParser.parse do |parser|
        parser.banner = "Usage: medup [arguments]"
        parser.on("-u USER", "--user=USER", "Medium author username. E.g: miry") { |u| user = u }
        parser.on("-h", "--help", "Show this help") { puts parser; exit = true }
        parser.on("-v", "--version", "Print current version") { puts ::Medup::VERSION; exit = true }

        parser.unknown_args do |before, after|
          msg = (before | after).join(" ")
        end
      end

      return if exit

      tool = ::Medup::Tool.new(token, user)
      tool.backup
      tool.close
    end
  end
end
