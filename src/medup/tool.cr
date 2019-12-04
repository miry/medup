module Medup
  class Tool
    def initialize(token : String)
      @client = Medium::Client.new(token)
    end

    def backup
      puts @client.me
    end

    def close : Nil
      @client.close unless @client.nil?
    end
  end
end
