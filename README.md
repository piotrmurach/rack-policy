# Rack-Policy

This is Rack middleware that makes your app compliant with the 'EU ePrivacy Directive'
whereby a user needs to provide implied consent before any data can be stored on his
machine.

## Installation

Add this line to your application's Gemfile:

    gem 'rack-policy'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rack-policy

## Usage

By default when the Rack application is loaded no cookies will be set(provided no session cookies already exist), and any existing session cookies will be destroyed. Throught the request cycle cookies now won't be set until the user has given explicit consent. This can be controlled by setting consent token

```ruby
Rack::Policy::CookieLimiter consent_token: 'allow_me'
```

## Examples

### Rails 3.x

```ruby
# config/application.rb
require 'rack/policy'

class Application < Rails::Application
  config.middleware.use Rack::Policy::CookieLimiter consent_token: 'rack.policy'
end
```

And then in your custome controller create actions responsible for setting and unsetting cookie policy

```ruby
class CookiePolicyController < ApplicationController
  def allow
    cookies[:consent_token] = {
      value: 'true',
      expires: 1.year.from_now.utc
    }
  end

  def deny
    cookies[:consent_token] = {
      value: '',
      expires: Time.at(0)
    }
  end
end
```

### Rails 2.x

```ruby
# config/environment

Rails::Initializer.run do |config|
  config.middleware.use Rack::Policy::Cookie :consent_token => 'rack.policy'
end
```

Set and unset cookie consent in similar way to Rails 3.x example.

### Sinatra

```ruby
require 'sinatra'
require 'rack/policy'

use Rack::Policy::CookieLimiter consent_token: 'rack.policy'

get('/hello') { "Hello world" }

get('/allow') { }
```

### Rackup app

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
