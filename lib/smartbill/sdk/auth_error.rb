# frozen_string_literal: true

module Smartbill
  module Sdk
    # Raised on HTTP 401 (bad credentials / company CIF).
    class AuthError < Error; end
  end
end
