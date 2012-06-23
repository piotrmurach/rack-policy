# -*- encoding: utf-8 -*-

require 'rack'

module Rack
  module Policy

    autoload :CookieLimiter,  'rack/policy/cookie_limiter'
    autoload :Version,        'rack/policy/version'

  end # Policy
end # Rack
