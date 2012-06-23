# RAILS_ENV=production bundle exec rackup -p 3000 -s thin

require 'rails'
require 'rails/all'
require 'rack/policy'

class MyApp < Rails::Application
  routes.append do
    match '/hello' => 'policy#hello'
    match '/allow' => 'policy#allow'
    match '/deny'  => 'policy#deny'
  end

  require 'rack/policy'

  config.middleware.use Rack::Policy::CookieLimiter
end

class PolicyController < ActionController::Base

  def hello
    response.set_cookie :custom_cookie, {
      :value => 'illegal cookie',
      :expires => 2.hours.from_now.utc
    }
    render :text => "Cookies #{cookies.inspect}"
  end

  def allow
    response.set_cookie :cookie_limiter, {
      :value => 'true',
      :expires => 2.hours.from_now.utc
    }
    render :text => "Cookies #{cookies.inspect}"
  end

  def deny
    response.delete_cookie :cookie_limiter
    render :text => "Cookies #{cookies.inspect}"
  end
end

MyApp.initialize!

# Print middleware stack
Rails.configuration.middleware.each do |middleware|
  puts "use #{middleware.inspect}"
end
puts "run #{Rails.application.class.name}.routes"

run MyApp
