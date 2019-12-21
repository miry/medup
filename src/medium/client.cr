require "http/client"
require "json"

require "./connection"
require "./client/*"

module Medium
  class Client
    @http : HTTP::Client?
    @@default = Medium::Client.new("", "")

    include Medium::Connection
    include Medium::Client::Users
    include Medium::Client::Posts
    include Medium::Client::Media

    def initialize(@token : String, @user : String?)
    end

    def self.default=(client : Medium::Client)
      @@default = client
    end

    def self.default
      @@default
    end

    def close
      http.close unless @http.nil?
    end
  end
end
