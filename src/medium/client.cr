require "http/client"
require "json"

require "logger"

require "./connection"
require "./client/*"

module Medium
  class Client
    @http = Hash(String, HTTP::Client).new
    @@default = Medium::Client.new("", "", "", Logger.new(STDOUT))

    include Medium::Client::Media
    include Medium::Client::Posts
    include Medium::Client::Publications
    include Medium::Client::Users
    include Medium::Connection

    def initialize(@token : String, @user : String?, @publication : String?, @logger : Logger)
    end

    def self.default=(client : Medium::Client)
      @@default = client
    end

    def self.default
      @@default
    end

    def close
      @http.each do |_, client|
        client.close
      end
    end
  end
end
