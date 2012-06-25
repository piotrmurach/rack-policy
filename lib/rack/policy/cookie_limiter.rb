# -*- encoding: utf-8 -*-

module Rack
  module Policy
    # This is the class for limiting cookie storage on client machine.
    class CookieLimiter
      include ::Rack::Utils

      HTTP_COOKIE   = "HTTP_COOKIE".freeze
      SET_COOKIE    = "Set-Cookie".freeze
      CACHE_CONTROL = "Cache-Control".freeze
      CONSENT_TOKEN = "cookie_limiter".freeze

      attr_reader :app, :options
      attr_accessor :status, :headers, :body

      # @option options [String] :consent_token
      #
      def initialize(app, options={})
        @app, @options = app, options
      end

      def consent_token
        @consent_token ||= options[:consent_token] || CONSENT_TOKEN
      end

      def expires
        Time.parse(options[:expires]) if options[:expires]
      end

      def call(env)
        dup.call!(env)
      end

      def call!(env)
        self.status, self.headers, self.body = @app.call(env)
        request = Rack::Request.new(env)
        response = Rack::Response.new body, status, headers
        clear_cookies!(request, response) unless allowed?(request)
        finish(env)
      end

      # Returns `false` if the cookie policy disallows cookie storage
      # for a given request, or `true` otherwise.
      #
      def allowed?(request)
        if ( request.cookies.has_key?(consent_token.to_s) ||
             parse_cookies.has_key?(consent_token.to_s) )
          true
        else
          false
        end
      end

      # Finish http response with proper headers
      def finish(env)
        if [204, 304].include?(status.to_i)
          headers.delete "Content-Type"
          [status.to_i, headers, []]
        elsif env['REQUEST_METHOD'] == 'HEAD'
          [status.to_i, headers, []]
        else
          [status.to_i, headers, body]
        end
      end

      protected

      # Returns the response cookies converted to Hash
      #
      def parse_cookies
        cookies = {}
        if header = headers[SET_COOKIE]
          header = header.split("\n") if header.respond_to?(:to_str)
          header.each do |cookie|
            if pair = cookie.split(';').first
              key, value = pair.split('=').map { |v| ::Rack::Utils.unescape(v) }
              cookies[key] = value
            end
          end
        end
        cookies
      end

      def clear_cookies!(request, response)
        cookies = parse_cookies
        headers.delete(SET_COOKIE)
        request.env.delete(HTTP_COOKIE)
        revalidate_cache!

        cookies.merge(request.cookies).each do |key, value|
          response.delete_cookie key.to_sym
        end

        headers
      end

      def revalidate_cache!
        headers.merge!({ CACHE_CONTROL => 'must-revalidate, max-age=0' })
      end

      def set_cookie(key, value)
        ::Rack::Utils.set_cookie_header!(headers, key, value)
      end

      def delete_cookie(key, value)
        ::Rack::Utils.delete_cookie_header!(headers, key, value)
      end

    end # CookieLimiter
  end # Policy
end # Rack
