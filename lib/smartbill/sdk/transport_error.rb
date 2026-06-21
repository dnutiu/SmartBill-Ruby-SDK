# frozen_string_literal: true

module Smartbill
  module Sdk
    # Raised on a network / transport-level failure.
    class TransportError < Error; end
  end
end
