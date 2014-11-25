# coding: utf-8

require File.expand_path('../spec_helper.rb', __FILE__)

class HelperTest
  attr_accessor :request
  include Rack::Policy::Helpers

  def initialize
    @request = HelperTest::Request.new
  end

  class Request
    attr_reader :env
    def initialize; @env = {}; end
  end
end

RSpec.describe Rack::Policy::Helpers do
  let(:helper_test) { HelperTest.new }

  before do
    allow(helper_test.request.env).to receive(:has_key?).and_return(true)
  end

  it "guards against missing key" do
    allow(helper_test.request.env).to receive(:has_key?).and_return(false)
    expect(helper_test.cookies_accepted?).to eq(false)
  end

  it "doesn't accept cookies" do
    allow(helper_test.request.env).to receive(:[]).with('rack-policy.consent') { nil }
    expect(helper_test.cookies_accepted?).to eq(false)
  end

  it "accepts cookies" do
    allow(helper_test.request.env).to receive(:[]).with('rack-policy.consent') { 'true' }
    expect(helper_test.cookies_accepted?).to eq(true)
  end

  it "yields to the block" do
    allow(helper_test.request.env).to receive(:[]).with('rack-policy.consent') { 'true' }
    block = Proc.new { 'Accepted'}
    expect(helper_test).to receive(:cookies_accepted?).and_yield(&block)
    helper_test.cookies_accepted?(&block)
  end
end # Rack::Policy::Helpers
