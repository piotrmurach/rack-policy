require 'sinatra'
require 'rack/policy'

configure do
  use Rack::Policy::CookieLimiter
end

get '/' do
  response.set_cookie 'foo', 'bar'
end

get '/allow' do
  response.set_cookie 'rack.policy', :expires => Time.now + 360
end

get '/deny' do
  response.delete_cookie 'rack.policy'
end
