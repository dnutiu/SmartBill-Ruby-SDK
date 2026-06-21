# frozen_string_literal: true

# smartbill-sdk — Ruby SDK for the SmartBill Cloud REST API.
#
# Provides a synchronous {Client} with typed request/response models for
# every endpoint in the SmartBill OpenAPI specification.
#
# Constants under `Smartbill::Sdk` are autoloaded by Zeitwerk from
# `lib/smartbill/sdk/` (one file per constant). `require "smartbill/sdk"`
# sets up the loader; constants are then resolved on first reference.

require "zeitwerk"

module Smartbill
  # Namespace for the SmartBill SDK.
  module Sdk
  end
end

loader = Zeitwerk::Loader.new
loader.push_dir(File.expand_path("sdk", __dir__), namespace: Smartbill::Sdk)
# `version.rb` defines the `VERSION` constant (not `Version`), and
# `api_error.rb` defines `APIError` (not `ApiError`).
loader.inflector.inflect(
  "version" => "VERSION",
  "api_error" => "APIError"
)
loader.setup

# Public alias for the default SmartBill Cloud REST API base URL.
Smartbill::Sdk::DEFAULT_BASE_URL = Smartbill::Sdk::Transport::DEFAULT_BASE_URL
