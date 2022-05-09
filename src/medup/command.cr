require "option_parser"

require "logger"

module Medup
  class Command
    def self.run
      settings = ::Medup::Settings.new
      settings.medium_token = ENV.fetch("MEDIUM_TOKEN", nil)
      settings.github_api_token = ENV.fetch("MEDUP_GITHUB_API_TOKEN", nil)

      user = nil
      publication = nil
      format = ::Medup::Tool::MARKDOWN_FORMAT
      source = ::Medup::Tool::SOURCE_AUTHOR_POSTS
      log_level : Int8 = 1_i8

      should_exit = false

      parser = OptionParser.parse do |parser|
        parser.banner = "Usage:\n  medup [arguments] [@user or publication name or url]\n"
        parser.on("-u USER", "--user=USER", "Medium author username. Download alrticles for this author. E.g: miry") { |u| user = u }
        parser.on("-p PUBLICATION", "--publication=PUBLICATION", "Medium publication slug. Download articles for the publication. E.g: jetthoughts") { |pub| publication = pub }
        parser.on("-d DIRECTORY", "--directory=DIRECTORY", "Path to local directory where articles should be dumped. Default: ./posts") { |d| settings.posts_dist = d }
        parser.on("-f FORMAT", "--format=FORMAT", "Specify the document format. Available options: md or json. Default: md") do |f|
          format = f
          unless [::Medup::Tool::MARKDOWN_FORMAT, ::Medup::Tool::JSON_FORMAT].includes?(format)
            puts "Unknown format option: #{format}"
            puts parser
            should_exit = true
          end
        end
        parser.on("--assets-images", "Download images in assets folder. By default all images encoded in the same markdown document.") { settings.set_assets_image! }
        parser.on("--assets-dir=DIRECTORY", "Path to local directory where assets should be dumped. Default: ./posts/assets") { |d| settings.assets_dist = d }
        parser.on("--assets-base-path=URL_BASE_PATH", "URL path in markdown for assets. Default: ./assets") { |u| settings.assets_base_path = u }
        parser.on("-r", "--recommended", "Export all posts to wich user clapped / has recommended") { source = ::Medup::Tool::SOURCE_RECOMMENDED_POSTS }
        parser.on("--update", "Overwrite existing articles files, if the same article exists") { settings.set_update_content! }
        parser.on("-h", "--help", "Show this help") { puts parser; should_exit = true }
        parser.on("--version", "Print current version") { puts ::Medup::VERSION; should_exit = true }
        parser.on("-v LEVEL", "--v=LEVEL", "Number for the log level verbosity. E.g.: -v7") { |l| log_level = l.to_i8 }

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

      logger = Logger.new(STDERR, level: log_level)
      ctx = ::Medup::Context.new(settings, logger)
      backup(ctx, user, publication, articles, format, source)
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

    def self.backup(
      ctx : ::Medup::Context,
      user,
      publication,
      articles,
      format,
      source
    )
      targets = extract_targets(articles)

      # Backup single posts
      if targets[:articles].size > 0
        tool = ::Medup::Tool.new(
          ctx,
          articles: targets[:articles],
          format: format,
          source: source,
        )
        tool.backup
        tool.close
      end

      # Backup articles per user
      (targets[:users] + [user]).compact.each do |u|
        tool = ::Medup::Tool.new(
          ctx,
          user: u,
          format: format,
          source: source,
        )
        tool.backup
        tool.close
      end

      # Backup articles per publication
      (targets[:publications] + [publication]).compact.each do |p|
        tool = ::Medup::Tool.new(
          ctx,
          publication: p,
          format: format,
          source: source,
        )
        tool.backup
        tool.close
      end
    rescue ex : Exception
      STDERR.puts "error: #{ex.inspect}"
      ctx.logger.debug 6_i8, ex.inspect_with_backtrace
      STDERR.puts "See 'medup --help' for usage."
      exit(1)
    end
  end
end
