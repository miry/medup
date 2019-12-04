module Medup
  class Tool
    user : String?

    def initialize(token : String, @user : String?)
      @client = Medium::Client.new(token, @user)
    end

    def backup
      raise "No user set" if @user.nil?
      puts @client.user(@user.not_nil!)
    end

    def close : Nil
      @client.close unless @client.nil?
    end
  end
end
