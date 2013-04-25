# -*- encoding: utf-8 -*-

require File.expand_path('../spec_helper.rb', __FILE__)

describe Rack::Policy::CookieLimiter do

  it 'preserves normal requests' do
    get('/').should be_ok
    last_response.body.should == 'ok'
  end

  it "does not meter where the middleware is inserted" do
    mock_app {
      use Rack::Policy::CookieLimiter
      use Rack::Session::Cookie, :key => 'app.session', :path => '/', :secret => 'foo'
      run DummyApp
    }
    get '/'
    last_response.should be_ok
    last_response.headers['Set-Cookie'].should be_nil
  end

  context 'no consent' do
    it 'removes cookie session header' do
      mock_app {
        use Rack::Policy::CookieLimiter
        run DummyApp
      }
      request '/'
      last_response.should be_ok
      last_response.headers['Set-Cookie'].should be_nil
    end

    it 'clears all the cookies' do
      mock_app {
        use Rack::Policy::CookieLimiter, :consent_token => 'consent'
        run DummyApp
      }
      set_cookie ["foo=1", "bar=2"]
      request '/'
      last_request.cookies.should == {}
    end

    it 'revalidates caches' do
      mock_app {
        use Rack::Policy::CookieLimiter
        run DummyApp
      }
      request '/'
      last_response.should be_ok
      last_response.headers['Cache-Control'].should =~ /must-revalidate/
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

    context 'token' do
      it 'preserves all the cookies if custom consent token present' do
        mock_app {
          use Rack::Policy::CookieLimiter, :consent_token => 'consent'
          run DummyApp
        }
        set_cookie ["foo=1", "bar=2", "consent=true"]
        request '/'
        last_request.cookies.should == {'foo'=>'1', 'bar'=>'2', 'consent'=>'true'}
      end
    end
  end

  context 'accepts?' do
    it "sets environment consent variable" do
       mock_app {
        use Rack::Policy::CookieLimiter
        run DummyApp
      }
      request '/'
      last_request.env.should have_key('rack-policy.consent')
    end

    it "assigns value for the consent variable" do
       mock_app {
        use Rack::Policy::CookieLimiter, :consent_token => 'consent'
        run DummyApp
      }
      set_cookie ["consent=true"]
      request '/'
      last_request.env['rack-policy.consent'].should == 'true'
    end
  end

  context 'finish response' do
    it 'returns correct response for head request' do
      mock_app {
        use Rack::Policy::CookieLimiter
        run DummyApp
      }
      head '/'
      last_response.should be_ok
    end

    it "strips content headers for no content" do
      mock_app with_status(204)
      get '/'
      last_response.headers['Content-Type'].should be_nil
      last_response.headers['Content-Length'].should be_nil
      last_response.body.should be_empty
    end

    it "strips headers for information request" do
      mock_app with_status(102)
      get '/'
      last_response.headers['Content-Length'].should be_nil
      last_response.body.should be_empty
    end
  end

end # Rack::Policy::CookieLimiter
