module Medium
  class Error < Exception
    def self.from_response(response : HTTP::Client::Response)
      klass = case response.status_code
              when 400..499 then ::Medium::ClientError
              when 500..599 then ::Medium::ServerError
              else               return
              end
      klass.new(response)
    end

    @data : JSON::Any? = nil

    def initialize(@response : HTTP::Client::Response = nil)
      super(build_error_message)
    end

    def build_error_message
      return nil if @response.nil?

      message = "#{@response.status_code} #{@response.status_message} "
      message += "#{response_error} " if response_error

      message
    end

    def response_error
      data.not_nil!["error"] if data
    end

    private def data
      return @data if @data

      case @response.status_code
      when 429
      else
        if @response.body
          _data = self.class.json(@response)
          @data = _data
        end
      end
      return @data
    end

    def self.json(response)
      JSON.parse(response.body[16..])
    end
  end

  class ClientError < Error; end

  class ServerError < Error; end
end
