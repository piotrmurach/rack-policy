# -*- encoding: utf-8 -*-
require File.expand_path('../lib/rack/policy/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Piotr Murach"]
  gem.email         = [""]
  gem.description   = %q{This is Rack middleware that makes your app compliant with the 'EU ePrivacy Directive'}
  gem.summary       = %q{This is Rack middleware that makes your app compliant with the 'EU ePrivacy Directive' whereby a user needs to provide implied consent before any data can be stored on his machine.}
  gem.homepage      = "https://github.com/peter-murach/rack-policy"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "rack-policy"
  gem.require_paths = ["lib"]
  gem.version       = Rack::Policy::VERSION

  gem.add_dependency 'rack', '~> 1.1'

  gem.add_development_dependency 'rack-test'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'rake'
end
