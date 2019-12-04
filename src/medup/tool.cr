module Medup
  class Tool
    user : String?

    def initialize(token : String, @user : String?)
      @client = Medium::Client.new(token, @user)
    end

    def backup
      raise "No user set" if @user.nil?
      posts = @client.posts
      puts  "Posts count: #{posts.size}"

      post_id = posts[0]["id"].raw.to_s
      p @client.post(post_id)
    end

    def close : Nil
      @client.close unless @client.nil?
    end
  end
end
