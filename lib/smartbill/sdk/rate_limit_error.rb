# frozen_string_literal: true

module Smartbill
  module Sdk
    # Raised on HTTP 403 — SmartBill blocks access for 10 minutes after
    # more than 30 calls / 10 seconds.
    class RateLimitError < Error; end
  end
end
