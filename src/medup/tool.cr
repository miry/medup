require "http/client"

module Medup
  class Tool
    DIST_PATH                = "./posts"
    SOURCE_AUTHOR_POSTS      = "overview"
    SOURCE_RECOMMENDED_POSTS = "has-recommended"
    MARKDOWN_FORMAT          = "md"
    JSON_FORMAT              = "json"

    token : String
    user : String?
    articles : Array(String)

    def initialize(@token : String, @user : String?, @articles : Array(String), dist : String?, format : String?, source : String?, update : Bool?)
      @client = Medium::Client.new(@token, @user)
      Medium::Client.default = @client
      @dist = (dist || DIST_PATH).as(String)
      @source = (source || SOURCE_AUTHOR_POSTS).as(String)
      @format = (format || MARKDOWN_FORMAT).as(String)
      @update = update.nil? ? false : update.not_nil!
    end

    def backup
      posts = Array(String).new
      if !@articles.empty?
        posts = @articles
      elsif !@user.nil?
        posts = @client.streams(@source)
      end

      if posts.empty?
        raise "No articles to backup"
      end

      process_posts_async(posts)
    end

    def process_posts_async(posts)
      puts "Posts count: #{posts.size}"

      channel_start = Channel(String).new(2)
      channel_finished = Channel(String).new(2)

      posts.each do |post_url|
        spawn do
          channel_start.send(post_url)
          process_post(post_url)
          channel_finished.send(post_url)
        end
      end

      posts.size.times do
        channel_start.receive?
        channel_finished.receive?
      end

      channel_start.close
      channel_finished.close
    end

    def close : Nil
      @client.close unless @client.nil?
    end

    def process_post(post_url : String)
      client = Medium::Client.new(@token, @user)
      post = client.post_by_url(post_url)
      save(post, @format)
      save_assets(post)
    rescue ex : Exception
      STDERR.puts "ERROR: #{ex.inspect}"
      STDERR.puts ex.inspect_with_backtrace
    ensure
      client.close unless client.nil?
    end

    def save(post, format = "json")
      slug = post.slug
      filename = slug + "." + format
      filepath = File.join(@dist, filename)
      unless File.directory?(@dist)
        puts "Create directory #{@dist}"
        Dir.mkdir_p(@dist)
      end

      assets_dir = File.join(@dist, "/assets")
      unless File.directory?(assets_dir)
        puts "Create directory #{assets_dir}"
        Dir.mkdir_p(assets_dir)
      end

      if File.exists?(filepath)
        return unless @update
        File.delete(filepath + ".old") if File.exists?(filepath + ".old")
        File.rename(filepath, filepath + ".old")
      end
      puts "Create file #{filepath}"

      File.write(filepath, post.format(format))
    end

    def save_assets(post)
      # puts post.to_pretty_json
      post.content.bodyModel.paragraphs.each do |paragraph|
        case paragraph.type
        when 11
          iframe = paragraph.iframe
          if !iframe.nil?
            download_iframe(iframe.mediaResourceId)
          end
        else
          # TODO: Record unknown assets
        end
      end
    end

    def download_iframe(name : String)
      filename = Zaru.sanitize!(name)
      download_to_assets("https://medium.com/media/#{name}", filename + ".html")
    end

    def download_to_assets(src, filename)
      filepath = File.join(@dist, "assets", filename)
      return if File.exists?(filepath)

      puts "Download file #{src} to #{filepath}"

      HTTP::Client.get(src) do |response|
        File.write(filepath, response.body_io)
      end
    end
  end
end
