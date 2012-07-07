# -*- encoding: utf-8 -*-

module Rack
  module Policy
    module Helpers

      def cookies_accepted?
        accepted = !request.env['rack-policy.consent'].nil?
        yield if block_given? && accepted
        accepted
      end

    end # Helpers
  end # Policy
end # Rack
