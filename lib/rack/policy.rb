# -*- encoding: utf-8 -*-

require 'rack'

module Rack
  module Policy

    autoload :CookieLimiter,  'rack/policy/cookie_limiter'
    autoload :Version,        'rack/policy/version'
    autoload :Helpers,        'rack/policy/helpers'

    # Initialize Rack::Policy extensions within an application
    require 'rack/policy/extensions'

  end # Policy
end # Rack
