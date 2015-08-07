require 'faraday'

# Yeah, this is almost a carbon copy of the way the Instagram gem does it.
# But screw it. It's open source, and it works. :P

module FaradayMiddleware
  class RaiseHttpException < Faraday::Middleware
    def call(env)
      @app.call(env).on_complete do |response|
        case response[:status].to_i
          when 400
            raise Dencity::BadRequest, error_message_400(response)
          when 401
            raise Dencity::Unauthorized, error_message_400(response)
          when 404
            raise Dencity::NotFound, error_message_400(response)
          when 406
            raise Dencity::NotAcceptable, error_message_400(response)
          when 500
            raise Dencity::InternalServerError, error_message_500(response, "Internal Server Error.")
        end
      end
    end

    def initialize(app)
      super app
      @parser = nil
    end

    private

    def error_message_400(response)
      "#{response[:method].to_s.upcase} #{response[:url].to_s}: #{response[:status]} #{error_body(response[:body])}"
    end

    def error_body(body)
      if not body.nil? and not body.empty? and body.kind_of?(String)
        body = ::MultiJson.load(body)
      end
    end

    def error_message_500(response, body=nil)
      "#{response[:method].to_s.upcase} #{response[:url].to_s}: #{[response[:status].to_s + ':', body].compact.join(' ')}"
    end
  end
end
