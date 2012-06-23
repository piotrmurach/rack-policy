require File.expand_path('../spec_helper.rb', __FILE__)

describe Rack::Policy::CookieLimiter do

  it 'preserves normal requests' do
    get('/').should be_ok
    last_response.body.should == 'ok'
  end

  it "does not meter where the middleware is inserted"

  context 'no consent' do
    it 'removes cookie session header' do
      mock_app DummyApp
      get '/'
      last_response.should be_ok
      last_response.headers['Set-Cookie'].should be_nil
    end

    it 'revalidates caches' do
      mock_app DummyApp
      get '/'
      last_response.should be_ok
      last_response.headers['Cache-Control'].should be_nil
    end
  end

  context 'with consent' do
    it 'preserves cookie header' do
      mock_app with_headers('Set-Cookie' => "cookie_limiter=true; path=/;")
      get '/'
      last_response.should be_ok
      last_response.headers['Set-Cookie'].should_not be_nil
    end

    it 'sets consent cookie' do
      mock_app with_headers('Set-Cookie' => "cookie_limiter=true; path=/;")
      get '/'
      last_response.headers['Set-Cookie'].should =~ /cookie_limiter/
    end

    it 'preserves other session cookies' do
      mock_app with_headers('Set-Cookie' => "cookie_limiter=true; path=/;\ngithub.com=bot")
      get '/'
      last_response.headers['Set-Cookie'].should =~ /github.com=bot/
    end
  end

end # Rack::Policy::CookieLimiter
