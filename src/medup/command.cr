require "option_parser"

module Medup
  class Command
    def self.run
      token = ENV.fetch("MEDIUM_TOKEN", "")
      user = nil
      dist = ::Medup::Tool::DIST_PATH
      format = ::Medup::Tool::MARKDOWN_FORMAT
      source = ::Medup::Tool::SOURCE_AUTHOR_POSTS
      update = false

      exit = false

      OptionParser.parse do |parser|
        parser.banner = "Usage: medup [arguments]"
        parser.on("-u USER", "--user=USER", "Medium author username. E.g: miry") { |u| user = u }
        parser.on("-d DIRECTORY", "--directory=DIRECTORY", "Path to local directory where articles should be dumped. Default: ./posts") { |d| dist = d }
        parser.on("-f FORMAT", "--format=FORMAT", "Specify the document format. Available options: md or json. Default: md") do |f|
          format = f
          unless [::Medup::Tool::MARKDOWN_FORMAT, ::Medup::Tool::JSON_FORMAT].includes?(format)
            puts "Unknown format option: #{format}"
            puts parser
            exit = true
          end
        end
        parser.on("-r", "--recommended", "Export all posts to wich user clapped / has recommended") { source = ::Medup::Tool::SOURCE_RECOMMENDED_POSTS }
        parser.on("-u", "--update", "Overwrite existing articles files, if the same article exists") { update = true }
        parser.on("-h", "--help", "Show this help") { puts parser; exit = true }
        parser.on("-v", "--version", "Print current version") { puts ::Medup::VERSION; exit = true }

        parser.unknown_args do |before, after|
          msg = (before | after).join(" ")
        end
      end

      return if exit

      tool = ::Medup::Tool.new(token: token, user: user, dist: dist, format: format, source: source, update: update)
      tool.backup
      tool.close
    rescue ex : Exception
      STDERR.puts "ERROR: #{ex.inspect}"
    end
  end
end
