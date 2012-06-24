# Rack-Policy
[![Build Status](https://secure.travis-ci.org/peter-murach/rack-policy.png?branch=master)][travis] [![Dependency Status](https://gemnasium.com/peter-murach/rack-policy.png?travis)][gemnasium]

[travis]: http://travis-ci.org/peter-murach/rack-policy
[gemnasium]: https://gemnasium.com/peter-murach/rack-policy

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

By default when the Rack application is loaded no cookies will be set(provided no session cookies already exist), and any existing session cookies will be destroyed. Throughout the request cycle cookies now won't be set until the user has given explicit consent. This can be controlled by setting consent token

```ruby
Rack::Policy::CookieLimiter consent_token: 'allow_me'
```

The very same `consent_token` is used to toggle the limiter behaviour.

## Examples

Adding `Rack::Policy::CookieLimiter` do Rack applications

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
    response.set_cookie 'rack.policy', {
      value: 'true',
      expires: 1.year.from_now.utc
    }
    render nothing: true
  end

  def deny
    response.delete_cookie 'rack.policy'
    render nothing: true
  end
end
```

### Rails 2.x

```ruby
# config/environment

Rails::Initializer.run do |config|
  config.middleware.use Rack::Policy::CookieLimiter consent_token: 'rack.policy'
end
```

Set and unset cookie consent in similar way to Rails 3.x example.

### Sinatra

For classic style sinatra application do

```ruby
#!/usr/bin/env ruby -rubygems
require 'sinatra'
require 'rack/policy'

use Rack::Policy::CookieLimiter consent_token: 'rack.policy'

get('/') { "Allow cookies to be set? <a href='/allow'>Allow</a>" }

get('/allow') { response.set_cookie 'rack.policy' }

get('/deny') { response.delete_cookie 'rack.policy' }
```

### Padrino app

### Rackup app

```ruby
#!/usr/bin/env rackup
require 'rack/policy'

use Rack::Policy::CookieLimiter consent_token: 'rack.policy'

run lambda { |env| [200, {'Content-Type' => 'text/plain'}, "Hello, world!\n"] }
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
