# coding: utf-8 -*-

RSpec.describe Rack::Policy::CookieLimiter do

  it 'preserves normal requests' do
    expect(get('/')).to be_ok
    expect(last_response.body).to eq('ok')
  end

  it "does not meter where the middleware is inserted" do
    mock_app {
      use Rack::Policy::CookieLimiter
      use Rack::Session::Cookie, :key => 'app.session', :path => '/', :secret => 'foo'
      run DummyApp
    }
    get '/'
    expect(last_response).to be_ok
    expect(last_response.headers['Set-Cookie']).to eq(nil)
  end

  context 'no consent' do
    it 'removes cookie session header' do
      mock_app {
        use Rack::Policy::CookieLimiter
        run DummyApp
      }
      request '/'
      expect(last_response).to be_ok
      expect(last_response.headers['Set-Cookie']).to eq(nil)
    end

    it 'clears all the cookies' do
      mock_app {
        use Rack::Policy::CookieLimiter, :consent_token => 'consent'
        run DummyApp
      }
      set_cookie ["foo=1", "bar=2"]
      request '/'
      expect(last_request.cookies).to eq({})
    end

    it 'revalidates caches' do
      mock_app {
        use Rack::Policy::CookieLimiter
        run DummyApp
      }
      request '/'
      expect(last_response).to be_ok
      expect(last_response.headers['Cache-Control']).to match(/must-revalidate/)
    end
  end

  context 'with consent' do
    it 'preserves cookie header' do
      mock_app with_headers('Set-Cookie' => "cookie_limiter=true; path=/;")
      get '/'
      expect(last_response).to be_ok
      expect(last_response.headers['Set-Cookie']).to_not eq(nil)
    end

    it 'sets consent cookie' do
      mock_app with_headers('Set-Cookie' => "cookie_limiter=true; path=/;")
      get '/'
      expect(last_response.headers['Set-Cookie']).to match(/cookie_limiter/)
    end

    it 'preserves other session cookies' do
      mock_app with_headers('Set-Cookie' => "cookie_limiter=true; path=/;\ngithub.com=bot")
      get '/'
      expect(last_response.headers['Set-Cookie']).to match(/github.com=bot/)
    end

    context 'token' do
      it 'preserves all the cookies if custom consent token present' do
        mock_app {
          use Rack::Policy::CookieLimiter, :consent_token => 'consent'
          run DummyApp
        }
        set_cookie ["foo=1", "bar=2", "consent=true"]
        request '/'
        expect(last_request.cookies).to eq({'foo'=>'1', 'bar'=>'2', 'consent'=>'true'})
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
      expect(last_request.env).to have_key('rack-policy.consent')
    end

    it "assigns value for the consent variable" do
       mock_app {
        use Rack::Policy::CookieLimiter, :consent_token => 'consent'
        run DummyApp
      }
      set_cookie ["consent=true"]
      request '/'
      expect(last_request.env['rack-policy.consent']).to eq('true')
    end
  end

  context 'finish response' do
    it 'returns correct response for head request' do
      mock_app {
        use Rack::Policy::CookieLimiter
        run DummyApp
      }
      head '/'
      expect(last_response).to be_ok
    end

    it "strips content headers for no content" do
      mock_app with_status(204)
      get '/'
      expect(last_response.headers['Content-Type']).to eq(nil)
      expect(last_response.headers['Content-Length']).to eq(nil)
      expect(last_response.body).to be_empty
    end

    it "strips headers for information request" do
      mock_app with_status(102)
      get '/'
      expect(last_response.headers['Content-Length']).to eq(nil)
      expect(last_response.body).to be_empty
    end
  end
end # Rack::Policy::CookieLimiter
