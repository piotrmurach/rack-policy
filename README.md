# Rack-Policy
[![Gem Version](https://badge.fury.io/rb/rack-policy.png)][gem]
[![Build Status](https://secure.travis-ci.org/piotrmurach/rack-policy.png?branch=master)][travis]
[![Code Climate](https://codeclimate.com/github/piotrmurach/rack-policy/badges/gpa.svg)][codeclimate]
[![Dependency Status](https://gemnasium.com/piotrmurach/rack-policy.png?travis)][gemnasium]
[![Coverage Status](https://coveralls.io/repos/github/piotrmurach/rack-policy/badge.svg)][coverage]
[![Inline docs](http://inch-ci.org/github/piotrmurach/rack-policy.svg?branch=master)][inchpages]

[gem]: http://badge.fury.io/rb/rack-policy
[travis]: http://travis-ci.org/piotrmurach/rack-policy
[codeclimate]: https://codeclimate.com/github/piotrmurach/rack-policy
[gemnasium]: https://gemnasium.com/piotrmurach/rack-policy
[coverage]: https://coveralls.io/github/piotrmurach/rack-policy
[inchpages]: http://inch-ci.org/github/piotrmurach/rack-policy

> This is Rack middleware that makes your app compliant with the 'EU ePrivacy Directive' whereby a user needs to provide implied consent before any data can be stored on his machine.

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
Rack::Policy::CookieLimiter, consent_token: 'allow_me'
```

The very same `consent_token` is used to toggle the limiter behaviour.

The `cookies_accepted?` view helper method is automatically loaded for Rails, Sinatra & Padrino apps.

## Examples

Adding `Rack::Policy::CookieLimiter` to Rack applications

### Rails 3.x

```ruby
# config/application.rb
require 'rack/policy'

class Application < Rails::Application
  config.middleware.insert_before ActionDispatch::Cookies, Rack::Policy::CookieLimiter, consent_token: 'rack.policy'
end
```

And then in your custom controller create actions responsible for setting and unsetting cookie policy

```ruby
class CookiePolicyController < ApplicationController

  def allow
    response.set_cookie 'rack.policy', {
      value: 'true',
      path: '/',
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

Finally, in your view you can use helper method `cookies_accepted?` to display/toggle cookie information

```ruby
<% cookies_accepted? do %>
  Accepted Cookies!
<% end %>

or

<% if cookies_accepted? %>
  Accepted Cookies!
<% else %>
  Cookies Not Accepted!
<% end %>
```

### Rails 2.x

```ruby
# config/environment

Rails::Initializer.run do |config|
  require 'rack/policy'
  config.middleware.insert_before Rack::Lock, Rack::Policy::CookieLimiter, consent_token: 'rack.policy'
end
```

Set and unset cookie consent in your controller and modify views logic in similar way to Rails 3.x example.

### Sinatra

For classic style sinatra application do

```ruby
#!/usr/bin/env ruby -rubygems
require 'sinatra'
require 'rack/policy'

configure do
  use Rack::Policy::CookieLimiter, consent_token: 'rack.policy'
end

get('/') { "Allow cookies to be set? <a href='/allow'>Allow</a>" }

get('/allow') { response.set_cookie 'rack.policy' }

get('/deny') { response.delete_cookie 'rack.policy' }
```

Similiar to Rails 3.x example you can use `cookies_accpeted?` helper to manage view logic related to cookie policy information.

### Padrino

```ruby
#!/usr/bin/env ruby -rubygems
require 'padrino'
require 'rack/policy'

class MyApp < Padrino::Application
  use Rack::Policy::CookieLimiter, consent_token: 'rack.policy'
end
```

### Rackup

```ruby
#!/usr/bin/env rackup
require 'rack/policy'

use Rack::Policy::CookieLimiter, consent_token: 'rack.policy'

run lambda { |env| [200, {'Content-Type' => 'text/plain'}, "Hello, world!\n"] }
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## Copyright

Copyright (c) 2012-2016 Piotr Murach. See LICENSE for further details.
