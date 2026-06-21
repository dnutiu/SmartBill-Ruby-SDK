# frozen_string_literal: true

module Smartbill
  module Sdk
    # Raised when a model fails validation (missing required fields).
    class ValidationError < Error; end
  end
end
