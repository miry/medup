require "option_parser"

module Medup
  class Command
    def self.run
      token = ENV.fetch("MEDIUM_TOKEN", "")
      user = nil
      dist = ::Medup::Tool::DIST_PATH
      exit = false

      OptionParser.parse do |parser|
        parser.banner = "Usage: medup [arguments]"
        parser.on("-u USER", "--user=USER", "Medium author username. E.g: miry") { |u| user = u }
        parser.on("-d DIRECTORY", "--directory=DIRECTORY", "Path to local directory where articles should be dumped. Default: ./posts") { |d| dist = d }
        parser.on("-h", "--help", "Show this help") { puts parser; exit = true }
        parser.on("-v", "--version", "Print current version") { puts ::Medup::VERSION; exit = true }

        parser.unknown_args do |before, after|
          msg = (before | after).join(" ")
        end
      end

      return if exit

      tool = ::Medup::Tool.new(token: token, user: user, dist: dist)
      tool.backup
      tool.close
    end
  end
end
