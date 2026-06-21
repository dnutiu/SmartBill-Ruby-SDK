# frozen_string_literal: true

module Smartbill
  module Sdk
    # Base class for all errors raised by the SDK.
    class Error < StandardError; end

    # Raised on HTTP 401 (bad credentials / company CIF).
    class AuthError < Error; end

    # Raised on HTTP 403 — SmartBill blocks access for 10 minutes after
    # more than 30 calls / 10 seconds.
    class RateLimitError < Error; end

    # Raised on a network / transport-level failure.
    class TransportError < Error; end

    # Raised when a model fails validation (missing required fields).
    class ValidationError < Error; end

    # Raised when the SmartBill API returns an error envelope or a non-2xx
    # response.
    #
    # @!attribute [r] error_text
    #   @return [String] the +errorText+ field from the API response.
    # @!attribute [r] message_field
    #   @return [String, nil] the optional +message+ field from the API.
    # @!attribute [r] status_code
    #   @return [Integer, nil] the HTTP status code, if available.
    class APIError < Error
      attr_reader :error_text, :message_field, :status_code

      def initialize(error_text: "", message: nil, status_code: nil)
        @error_text = error_text.to_s
        @message_field = message
        @status_code = status_code
        detail = @error_text.empty? ? (message || "SmartBill API error") : @error_text
        detail = "[#{status_code}] #{detail}" unless status_code.nil?
        super(detail)
      end
    end
  end
end
