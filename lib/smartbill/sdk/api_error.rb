# frozen_string_literal: true

module Smartbill
  module Sdk
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
