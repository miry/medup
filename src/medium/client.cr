require "http/client"
require "json"

require "./connection"
require "./client/*"

module Medium
  class Client
    @http : HTTP::Client?

    include Medium::Connection
    include Medium::Client::Users
    include Medium::Client::Posts

    def initialize(@token : String, @user : String?)
    end

    def close
      http.close unless @http.nil?
    end
  end
end
