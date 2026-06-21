# frozen_string_literal: true

# Re-exports for every SmartBill model. Mirrors the Python
# `smartbill_sdk.models` namespace.
module Smartbill
  module Sdk
    # Typed request/response models for the SmartBill Cloud REST API.
    module Models
    end
  end
end

require_relative "models/enums"
require_relative "models/base"
require_relative "models/common"
require_relative "models/invoices"
require_relative "models/estimates"
require_relative "models/payments"
require_relative "models/email"
require_relative "models/config"
require_relative "models/stocks"
require_relative "models/responses"
