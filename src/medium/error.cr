module Medium
  class Error < Exception
    def self.from_response(response : HTTP::Client::Response)
      klass = case response.status_code
              when 400..499 then ::Medium::ClientError
              when 500..599 then ::Medium::ServerError
              end
      if klass
        klass.new(response)
      end
    end

    @data : JSON::Any? = nil

    def initialize(@response : HTTP::Client::Response = nil)
      super(build_error_message)
    end

    def build_error_message
      return nil if @response.nil?

      message = "#{@response.status_code} #{@response.status_message} "
      message += "#{response_message} " if response_message

      message
    end

    def response_message
      if data
        data.not_nil!["message"]
      end
    end

    private def data
      return @data if @data

      if @response.body
        _data = JSON.parse(@response.body)
        @data = _data
      end

      return @data
    end
  end

  class ClientError < Error; end

  class ServerError < Error; end
end
