# -*- encoding: utf-8 -*-

module Rack
  module Policy
    class CookieLimiter
      include ::Rack::Utils

      SET_COOKIE    = "Set-Cookie".freeze
      CACHE_CONTROL = "Cache-Control".freeze
      CONSENT_TOKEN = "cookie_limiter".freeze

      attr_reader :app
      attr_reader :options
      attr_accessor :headers

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
        status, headers, body = app.call(env)
        self.headers = headers
        clear_cookies! unless allowed?
        [status, headers, body]
      end

      def allowed?
        if parse_cookies.has_key?(consent_token)
          true
        else
          false
        end
      end

      protected

      # Returns the response cookies converted to Hash
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

      def clear_cookies!
        headers.delete(SET_COOKIE)
        revalidate_cache!
        headers
      end

      def revalidate_cache!
        headers.merge!({ CACHE_CONTROL => 'must-revalidate, max-age=0' })
      end

      def set_cookie(key, value)
        ::Rack::Utils.set_cookie_header!(headers, key, value)
      end

    end # CookieLimiter
  end # Policy
end # Rack
