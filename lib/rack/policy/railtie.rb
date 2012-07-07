# -*- encoding: utf-8 -*-

module Rack
  module Policy
    class Railtie < ::Rails::Railtie
      initializer "rack-policy.view_helpers" do |app|
        ActionView::Base.send :include, Helpers
      end
    end # Railtie
  end # Policy
end # Rack
