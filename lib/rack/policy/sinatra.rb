# -*- encoding: utf-8 -*-

module Rack
  module Policy
    module Sinatra
      def self.registered(app)
        app.helpers Rack::Policy::Helpers
      end
    end # Sinatra
  end # Policy
end # Rack

Sinatra.register Rack::Policy::Sinatra
