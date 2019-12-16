require "http/client"

module Medup
  class Tool
    DIST_PATH = "./posts"

    user : String?

    def initialize(token : String?, @user : String?, dist : String?)
      @client = Medium::Client.new(token, @user)
      @dist = (dist || DIST_PATH).as(String)
    end

    def backup
      raise "No user set" if @user.nil?
      posts = @client.posts
      puts "Posts count: #{posts.size}"

      posts.each do |post_meta|
        post_id = post_meta["id"].raw.to_s
        post_slug = post_meta["slug"].raw.to_s
        post = @client.post(post_id)
        save(post, "md")
        save(post, "json")
        save_assets(post)
      end
    end

    def close : Nil
      @client.close unless @client.nil?
    end

    def save(post, format = "json")
      slug = post.slug
      filename = slug + "." + format
      filepath = File.join(@dist, filename)
      unless File.directory?(@dist)
        puts "Create directory #{@dist}"
        Dir.mkdir(@dist)
      end

      assets_dir = File.join(@dist, "/assets")
      unless File.directory?(assets_dir)
        puts "Create directory #{assets_dir}"
        Dir.mkdir(assets_dir)
      end

      if File.exists?(filepath)
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
        when 4
          metadata = paragraph.metadata
          if !metadata.nil?
            download_image(metadata.id)
          end
        end
      end
    end

    def download_image(name)
      filepath = File.join(@dist, "assets", name)
      return if File.exists?(filepath)

      puts "Downlod file to #{filepath}"

      HTTP::Client.get("https://miro.medium.com/#{name}") do |response|
        File.write(filepath, response.body_io)
      end
    end

    def download_url(href)
      uri = URI.parse href
      name = "#{uri.host}_#{uri.path}".gsub(/[\@\/]+/, "_")
      filepath = File.join(@dist_path, "assets", name)

      return if File.exists?(filepath)

      puts "Downlod #{href} file to #{filepath}"

      HTTP::Client.get(href) do |response|
        File.write(filepath, response.body_io)
      end
    end
  end
end
