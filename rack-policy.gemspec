# coding: utf-8
require File.expand_path('../lib/rack/policy/version', __FILE__)

Gem::Specification.new do |spec|
  spec.name          = "rack-policy"
  spec.version       = Rack::Policy::VERSION
  spec.authors       = ["Piotr Murach"]
  spec.email         = [""]
  spec.description   = %q{This is Rack middleware that makes your app compliant with the 'EU ePrivacy Directive'}
  spec.summary       = %q{This is Rack middleware that makes your app compliant with the 'EU ePrivacy Directive' whereby a user needs to provide implied consent before any data can be stored on his machine.}
  spec.homepage      = "https://github.com/peter-murach/rack-policy"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($\)
  spec.executables   = spec.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'rack', '~> 1.1'

  spec.add_development_dependency "bundler", "~> 1.6"
end
