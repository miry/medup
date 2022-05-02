require "./error"

module Medium
  module ConnectionAPI
    HOST = "api.medium.com"

    def get(endpoint, headers : HTTP::Headers? = nil, body : String? = nil)
      request "GET", endpoint, headers, body
    end

    def post(endpoint, headers : HTTP::Headers? = nil, body : String? = nil)
      request "POST", endpoint, headers, body
    end

    def patch(endpoint, headers : HTTP::Headers? = nil, body : String? = nil)
      request "PATCH", endpoint, headers, body
    end

    def http : HTTP::Client
      if !@http.nil?
        return @http.not_nil!
      end

      _http = HTTP::Client.new HOST, port: 443, tls: true

      _http.before_request do |request|
        request.headers["Content-Type"] = "application/json"
        request.headers["Authorization"] = "Bearer #{@token}" if !@token.empty?
      end

      @http = _http
      return _http
    end

    def request(method, endpoint, headers : HTTP::Headers? = nil, body : String? = nil)
      response = http.exec(method.upcase, endpoint, headers, body)

      puts "#{method} #{endpoint} => #{response.status_code} #{response.status_message}"

      error = Medium::Error.from_response(response)
      raise error if error

      JSON.parse(response.body)
    end
  end
end
