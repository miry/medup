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
      if File.exists?(filepath)
        File.delete(filepath + ".old") if File.exists?(filepath + ".old")
        File.rename(filepath, filepath + ".old")
      end
      puts "Create file #{filepath}"
      File.write(filepath, post["content"])
    end
  end
end
