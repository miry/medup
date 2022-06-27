require "uri"

require "./error"

module Devto
  module Connection
    HOST = "dev.to"

    def get(endpoint, params : Hash(String, String)? = nil, headers : HTTP::Headers? = nil, body : String? = nil)
      request "GET", endpoint, params, headers, body
    end

    def get_pagination(endpoint, params : Hash(String, String)? = nil, headers : HTTP::Headers? = nil, body : String? = nil, &block)
      params ||= Hash(String, String).new
      params["page"] ||= "1"
      params["per_page"] ||= "1000"

      page = params["page"].to_i
      while page < 1000
        response = get(endpoint, params, headers, body)
        break if response == "[]"
        yield response
        page += 1
        params["page"] = page.to_s
      end
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
      @logger.info "#{method} #{uri} => #{response.status_code} #{response.status_message}"

      limit = 10
      while limit > 0 && response.status_code >= 300 && response.status_code < 400
        endpoint = response.headers["location"]
        uri = URI.parse endpoint
        response = http(uri.host).exec(method: method.upcase, path: uri.request_target, headers: headers, body: body)
        @logger.info "#{method} #{uri} => #{response.status_code} #{response.status_message}"
        limit -= 1
      end

      @logger.info 12, response.body
      error = ::Devto::Error.from_response(response)
      raise error if error

      response.body
    end

    def download(endpoint : String)
      response = http.exec("GET", endpoint)
      @logger.debug "GET #{endpoint} => #{response.status_code} #{response.status_message}"
      error = Medium::Error.from_response(response)
      raise error if error
      response.body
    end
  end
end
