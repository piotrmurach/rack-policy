# -*- encoding: utf-8 -*-

# Autoload Rails extensions
if defined?(Rails) && Rails.respond_to?(:application)
  # Rails 3
  require 'rack/policy/railtie'

elsif defined?(Rails::Initializer)
  # Rails 2.3
  require 'action_view'

  ActionView::Base.send :include, Rack::Policy::Helpers
elsif defined?(Sinatra)
  require 'rack/policy/sinatra'

elsif defined?(Padrino)
  require 'padrino-core'
end
