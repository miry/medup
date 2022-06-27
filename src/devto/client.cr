require "json"

require "./connection"
require "./post"

module Devto
  class Client
    @http = Hash(String, HTTP::Client).new

    include ::Devto::Connection

    def initialize(@ctx : ::Medup::Context)
      @logger = @ctx.logger
    end

    # Retrive article from provider and convert build Post object.
    def post_by_url(url : String) : ::Devto::Post
      api_url = convert_to_api_url(url)
      response = get(api_url)
      result = Devto::Post.from_json(response)
      result.ctx = @ctx
      result
    end

    def post_urls_by_author(author : String)
      api_url = "https://dev.to/api/articles"
      base_url = api_url + "/" + author + "/"
      result = [] of String
      get_pagination(api_url, {"username" => author}) do |response|
        overviews = JSON.parse(response).as_a.map do |a|
          base_url + a["slug"].as_s
        end
        result += overviews
      end
      result
    end

    # Converts public article url to api format url.
    # in: https://dev.to/jetthoughts/how-to-use-linear-gradient-in-css-bi1
    # out: https://dev.to/api/articles/jetthoughts/how-to-use-linear-gradient-in-css-bi1
    def convert_to_api_url(url : String) : String
      return url if url[0..27] == "https://dev.to/api/articles/"
      url.sub("https://dev.to/", "https://dev.to/api/articles/")
    end

    def close
      @http.each do |_, client|
        client.close
      end
    end
  end
end
