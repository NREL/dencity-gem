module Dencity
  # Request module
  module Request
    # Perform an HTTP GET request (options should not be in JSON)
    def get(path, options = {}, raw = false,
      unformatted = false, no_response_wrapper = false)
      request(:get, path, options, raw, unformatted, no_response_wrapper)
    end

    # Perform an HTTP POST request (options should be in JSON already)
    def post(path, options = {}, raw = false,
      unformatted = false, no_response_wrapper = false)
      request(:post, path, options, raw, unformatted, no_response_wrapper)
    end

    private

    # Perform an HTTP request
    def request(method, path, options, raw = false,
      unformatted = false, no_response_wrapper = false)
      response = @connection.send(method) do |request|
        path = formatted_path(path) unless unformatted
        puts "PATH: #{path}"

        case method
          when :get, :delete
          request.url(path, options)
        when :post, :put
          request.path = path
          request.body = options unless options.empty?
        end

        request.headers['Content-Type'] = 'application/json'

      end
      #puts "RESPONSE STATUS: #{response.status}"
      #puts "RESPONSE BODY: #{response.body}"
      return response if raw
      return response.body if no_response_wrapper
      Response.create(response.body)
    end

    def formatted_path(path)
      [path, 'json'].compact.join('.')
    end
  end
end
