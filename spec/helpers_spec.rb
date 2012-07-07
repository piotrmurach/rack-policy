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

describe Rack::Policy::Helpers do

  let(:helper_test) { HelperTest.new }

  it "doesn't accept cookies" do
    helper_test.request.env.stub(:[]).with('rack-policy.consent') { nil }
    helper_test.cookies_accepted?.should be_false
  end

  it "accepts cookies" do
    helper_test.request.env.stub(:[]).with('rack-policy.consent') { 'true' }
    helper_test.cookies_accepted?.should be_true
  end

  it "yields to the block" do
    helper_test.request.env.stub(:[]).with('rack-policy.consent') { 'true' }
    block = Proc.new { 'Accepted'}
    helper_test.should_receive(:cookies_accepted?).and_yield(&block)
    helper_test.cookies_accepted?(&block)
  end

end # Rack::Policy::Helpers
