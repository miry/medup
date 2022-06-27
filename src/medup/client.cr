require "../devto/client"
require "../medium/client"

module Medup
  class Client
    @adapters = Hash(String, ::Devto::Client | ::Medium::Client).new
    @adapter : (::Devto::Client | ::Medium::Client | Nil)

    def initialize(@ctx : ::Medup::Context, @user : String?, @publication : String?)
      initialize_adapters!
      @adapter = @adapters[@ctx.settings.platform]
    end

    def initialize_adapters!
      @adapters = {
        ::Medup::Settings::PLATFORM_DEVTO  => ::Devto::Client.new(ctx: @ctx),
        ::Medup::Settings::PLATFORM_MEDIUM => ::Medium::Client.new(@user, @publication, @ctx.logger),
      }
    end

    def adapter
      @adapter
    end

    def post_by_url(url : String)
      if url.includes?("https://dev.to/")
        client = @adapters[::Medup::Settings::PLATFORM_DEVTO]
        post = client.post_by_url(url)
        return post
      end

      client = @adapters[::Medup::Settings::PLATFORM_MEDIUM]
      post = client.post_by_url(url)
      post.ctx = @ctx
      return post
    end

    def post_urls_by_author(author : String)
      instance = @adapter
      return Array(String).new if instance.nil?
      instance.post_urls_by_author(author)
    end

    def close
      @adapters.values.each &.close
    end
  end
end
