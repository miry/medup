require "./error"
require "uri"

module Medium
  module Connection
    HOST           = "medium.com"
    DEFAULT_PARAMS = {"format" => "json"}

    def get(endpoint, params : Hash(String, String)? = nil, headers : HTTP::Headers? = nil, body : String? = nil)
      params = DEFAULT_PARAMS.merge(params || Hash(String, String).new)
      request "GET", endpoint, params, headers, body
    end

    def http(host : String? = HOST) : HTTP::Client
      host ||= HOST
      if @http.has_key?(host)
        return @http[host].not_nil!
      end

      _http = HTTP::Client.new host, port: 443, tls: true

      _http.before_request do |request|
        request.headers["Content-Type"] = "application/json"
        request.headers["User-Agent"] = "medup/#{Medup::VERSION}"
        request.headers["Accept"] = "*/*"
      end

      @http[host] = _http
      return _http
    end

    def request(method, endpoint, params : Hash(String, String)? = nil, headers : HTTP::Headers? = nil, body : String? = nil)
      uri = URI.parse endpoint
      if params
        o = uri.query_params
        params.each { |k, v| o.add(k, v) }
        uri.query_params = o
      end

      response = http(uri.host).exec(method: method.upcase, path: uri.request_target, headers: headers, body: body)
      puts "#{method} #{uri} => #{response.status_code} #{response.status_message}"

      limit = 10
      while limit > 0 && response.status_code >= 300 && response.status_code < 400
        endpoint = response.headers["location"]
        uri = URI.parse endpoint
        response = http(uri.host).exec(method: method.upcase, path: uri.request_target, headers: headers, body: body)
        puts "#{method} #{uri} => #{response.status_code} #{response.status_message}"
        limit -= 1
      end

      error = Medium::Error.from_response(response)
      raise error if error

      JSON.parse(response.body[16..])
    end

    def download(endpoint : String)
      response = http.exec("GET", endpoint)
      puts "GET #{endpoint} => #{response.status_code} #{response.status_message}"
      error = Medium::Error.from_response(response)
      raise error if error
      response.body
    end
  end
end
