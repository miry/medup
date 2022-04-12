require "option_parser"
require "logger"

module Medup
  class Command
    def self.run
      token = ENV.fetch("MEDIUM_TOKEN", "")
      user = nil
      publication = nil
      dist = ::Medup::Tool::DIST_PATH
      format = ::Medup::Tool::MARKDOWN_FORMAT
      source = ::Medup::Tool::SOURCE_AUTHOR_POSTS
      options = Array(::Medup::Options).new
      log_level = 1

      should_exit = false

      parser = OptionParser.parse do |parser|
        parser.banner = "Usage:\n  medup [arguments] [@user or publication name or url]\n"
        parser.on("-u USER", "--user=USER", "Medium author username. Download alrticles for this author. E.g: miry") { |u| user = u }
        parser.on("-p PUBLICATION", "--publication=PUBLICATION", "Medium publication slug. Download articles for the publication. E.g: jetthoughts") { |pub| publication = pub }
        parser.on("-d DIRECTORY", "--directory=DIRECTORY", "Path to local directory where articles should be dumped. Default: ./posts") { |d| dist = d }
        parser.on("-f FORMAT", "--format=FORMAT", "Specify the document format. Available options: md or json. Default: md") do |f|
          format = f
          unless [::Medup::Tool::MARKDOWN_FORMAT, ::Medup::Tool::JSON_FORMAT].includes?(format)
            puts "Unknown format option: #{format}"
            puts parser
            should_exit = true
          end
        end
        parser.on("--assets-images", "Download images in assets folder. By default all images encoded in the same markdown document.") { options << ::Medup::Options::ASSETS_IMAGE }
        parser.on("-r", "--recommended", "Export all posts to wich user clapped / has recommended") { source = ::Medup::Tool::SOURCE_RECOMMENDED_POSTS }
        parser.on("--update", "Overwrite existing articles files, if the same article exists") { options << ::Medup::Options::UPDATE_CONTENT }
        parser.on("-h", "--help", "Show this help") { puts parser; should_exit = true }
        parser.on("--version", "Print current version") { puts ::Medup::VERSION; should_exit = true }
        parser.on("-v LEVEL", "--v=LEVEL", "number for the log level verbosity") { |l| log_level = l.to_i }

        parser.missing_option do |option_flag|
          STDERR.puts "error: flag needs an argument: #{option_flag}"
          STDERR.puts "See 'medup --help' for usage."
          exit(1)
        end

        parser.invalid_option do |option_flag|
          STDERR.puts "error: unknown flag: #{option_flag}"
          STDERR.puts "See 'medup --help' for usage."
          exit(1)
        end
      end

      articles = ARGV

      if !should_exit && user.nil? && publication.nil? && articles.empty?
        STDERR.puts "error: missing of the required arguments"
        STDERR.puts "See 'medup --help' for usage."
        exit(1)
      end

      return if should_exit

      log = setup_logger(log_level)
      backup(user, publication, articles, token, dist, format, source, options, log)
    end

    def self.setup_logger(level = 0)
      Logger.new(STDOUT, level: Logger::Severity.new(level))
    end

    def self.extract_targets(input)
      users = Array(String).new
      publications = Array(String).new
      articles = Array(String).new

      input.each do |word|
        case word
        when /^\@.*/
          users << word[1..]
        when /^https?:\/\/.*/
          articles << word
        else
          publications << word
        end
      end

      return {users: users, publications: publications, articles: articles}
    end

    def self.backup(user, publication, articles, token, dist, format, source, options, log)
      targets = extract_targets(articles)

      # Backup single posts
      if targets[:articles].size > 0
        tool = ::Medup::Tool.new(
          token: token,
          articles: targets[:articles],
          dist: dist,
          format: format,
          source: source,
          options: options,
          logger: log,
        )
        tool.backup
        tool.close
      end

      # Backup articles per user
      (targets[:users] + [user]).compact.each do |u|
        tool = ::Medup::Tool.new(
          token: token,
          user: u,
          dist: dist,
          format: format,
          source: source,
          options: options,
          logger: log,
        )
        tool.backup
        tool.close
      end

      # Backup articles per publication
      (targets[:publications] + [publication]).compact.each do |p|
        tool = ::Medup::Tool.new(
          token: token,
          publication: p,
          dist: dist,
          format: format,
          source: source,
          options: options,
          logger: log,
        )
        tool.backup
        tool.close
      end
    rescue ex : Exception
      STDERR.puts "error: #{ex.inspect}"
      log.error ex.inspect_with_backtrace
      STDERR.puts "See 'medup --help' for usage."
      exit(1)
    end
  end
end
