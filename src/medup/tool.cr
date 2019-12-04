
require "http/client"

module Medup
  class Tool
    DIST_PATH = "./posts"

    user : String?

    def initialize(token : String, @user : String?)
      @client = Medium::Client.new(token, @user)
    end

    def backup
      raise "No user set" if @user.nil?
      posts = @client.posts
      puts  "Posts count: #{posts.size}"

      posts.each do |post_meta|
        post_id = post_meta["id"].raw.to_s
        post_slug = post_meta["slug"].raw.to_s
        post  = @client.post(post_id)
        save(post)
        save_assets(post)
      end
    end

    def close : Nil
      @client.close unless @client.nil?
    end

    def save(post)
      slug = post["slug"].raw.to_s
      filename = slug + ".json"
      filepath = File.join(DIST_PATH, filename)
      unless File.directory?(DIST_PATH)
        puts "Create directory #{DIST_PATH}"
        Dir.mkdir(DIST_PATH)
      end

      unless File.directory?(DIST_PATH+"/assets")
        puts "Create directory #{DIST_PATH}/assets"
        Dir.mkdir(DIST_PATH+"/assets")
      end

      if File.exists?(filepath)
        File.delete(filepath + ".old") if File.exists?(filepath + ".old")
        File.rename(filepath, filepath + ".old")
      end
      puts "Create file #{filepath}"
      File.write(filepath, post["content"].to_pretty_json)
    end

    def save_assets(post)
      # puts post.to_pretty_json
      post["content"]["bodyModel"]["paragraphs"].raw.as(Array).each do |paragraph|
        case paragraph["type"].raw
        when 4
          download_image(paragraph["metadata"]["id"].raw.to_s)
        end
      end
    end

    def download_image(name)
      filepath = File.join(DIST_PATH, "assets", name)
      return if File.exists?(filepath)

      puts "Downlod file to #{filepath}"

      HTTP::Client.get("https://miro.medium.com/#{name}") do |response|
        File.write(filepath, response.body_io)
      end
    end

    def download_url(href)
      uri = URI.parse href
      name = "#{uri.host}_#{uri.path}".gsub(/[\@\/]+/, "_")
      filepath = File.join(DIST_PATH, "assets", name)

      return if File.exists?(filepath)

      puts "Downlod #{href} file to #{filepath}"

      HTTP::Client.get(href) do |response|
        File.write(filepath, response.body_io)
      end
    end
  end
end
