# frozen_string_literal: true

require_relative "transport"
require_relative "http_adapter"
require_relative "services"

module Smartbill
  module Sdk
    # Synchronous client for the SmartBill Cloud REST API.
    #
    # Usage:
    #
    #   client = Smartbill::Sdk::Client.new(username: "you@example.com", token: "...")
    #   resp = client.invoices.create(invoice)
    #   puts resp.series, resp.number
    #   client.close
    #
    # Or with a block (closes automatically):
    #
    #   Smartbill::Sdk::Client.new(username: "...", token: "...") do |client|
    #     client.invoices.create(invoice)
    #   end
    class Client
      attr_reader :username, :token, :base_url, :auth_header,
                  :invoices, :estimates, :payments, :email, :taxes, :series, :stocks

      def initialize(username:, token:, base_url: Transport::DEFAULT_BASE_URL,
                     timeout: Transport::DEFAULT_TIMEOUT, enforce_rate_limit: false,
                     http: nil)
        @username = username
        @token = token
        @base_url = base_url
        @auth_header = Transport.build_auth(username, token)
        @rate_limiter = enforce_rate_limit ? Transport::RateLimiter.new : nil
        @http = http || NetHttpAdapter.new(timeout: timeout)
        @invoices  = Services::InvoicesService.new(self)
        @estimates = Services::EstimatesService.new(self)
        @payments  = Services::PaymentsService.new(self)
        @email     = Services::EmailService.new(self)
        @taxes     = Services::ConfigurationService.new(self)
        @series    = @taxes # convenience alias: taxes + series share one service
        @stocks    = Services::StocksService.new(self)
      end

      # Send a {Transport::Request} and return the parsed payload.
      # When +binary+ is true, the raw body String is returned.
      def execute(request, binary: false)
        @rate_limiter&.acquire
        response = begin
          @http.call(request)
        rescue Error, AuthError, APIError, RateLimitError, ValidationError => e
          raise e
        rescue StandardError => e
          raise TransportError, "Transport error: #{e.message}"
        end
        @rate_limiter&.notify_403 if response.status == 403 && @rate_limiter
        Transport.handle_response(response, binary: binary)
      end

      # Close the underlying HTTP adapter. A no-op for the default
      # +Net::HTTP+ adapter (which opens a fresh connection per request).
      def close; end

      # Yield self to a block and ensure +#close+ is called afterwards.
      def with_client
        yield self
      ensure
        close
      end
    end
  end
end
