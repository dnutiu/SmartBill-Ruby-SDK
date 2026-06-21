# frozen_string_literal: true

require_relative "sdk/version"
require_relative "sdk/exceptions"
require_relative "sdk/transport"
require_relative "sdk/http_adapter"
require_relative "sdk/models"
require_relative "sdk/services"
require_relative "sdk/client"

# smartbill-sdk — Ruby SDK for the SmartBill Cloud REST API.
#
# Provides a synchronous {Smartbill::Sdk::Client} with typed request/response
# models for every endpoint in the SmartBill OpenAPI specification.
module Smartbill
  module Sdk
    # SmartBill Cloud REST API base URL.
    DEFAULT_BASE_URL = Transport::DEFAULT_BASE_URL
  end
end
