# coding: utf-8

if RUBY_VERSION > '1.9' and (ENV['COVERAGE'] || ENV['TRAVIS'])
  require 'simplecov'
  require 'coveralls'

  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
    SimpleCov::Formatter::HTMLFormatter,
    Coveralls::SimpleCov::Formatter
  ]

  SimpleCov.start do
    command_name 'spec'
    add_filter 'spec'
  end
end

require 'rack/test'
require 'rack/policy'

module DummyApp
  def self.call(env)
    Thread.current[:last_env] = env
    [200, {'Content-Type' => 'text/plain'}, ['ok']]
  end
end

module TestHelpers
  def app
    @app ||= mock_app(DummyApp)
  end

  def mock_app(app=nil, opts={}, &block)
    app = block if app.nil? and block.arity == 1
    if app
      mock_app do
        use Rack::Policy::CookieLimiter, opts
        run app
      end
    else
      @app = Rack::Lint.new Rack::Builder.new(&block).to_app
    end
  end

  def with_headers(headers)
    proc { [200, {'Content-Type' => 'text/plain' }.merge(headers), ['ok']] }
  end

  def with_status(status=nil)
    proc { [status || 200, {'Content-Type' => 'text/plain' }, ['ok']] }
  end
end

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
  config.disable_monkey_patching!
  config.warnings = true
  config.order = :random
  config.include Rack::Test::Methods
  config.include TestHelpers
end
