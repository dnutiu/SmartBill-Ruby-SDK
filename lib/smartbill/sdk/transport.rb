# frozen_string_literal: true

require "base64"
require "json"
require "time"

require_relative "exceptions"

module Smartbill
  module Sdk
    # Shared transport logic for the SmartBill clients.
    #
    # The SmartBill API uses HTTP Basic Auth with +username:token+ and
    # returns JSON envelopes whose root key depends on the endpoint
    # (+sbcResponse+, +Response+, +sbcInvoicePaymentStatusResponse+,
    # +sbcSeries+, +sbcTaxes+, +stocks+, +Fault+). This module centralises
    # request building, auth, envelope unwrapping and error mapping so the
    # clients stay DRY.
    module Transport
      DEFAULT_BASE_URL = "https://ws.smartbill.ro/SBORO/api/"
      DEFAULT_TIMEOUT = 30.0

      # Envelope root keys used by SmartBill responses.
      ENVELOPE_KEYS = %w[
        sbcResponse
        Response
        sbcInvoicePaymentStatusResponse
        sbcSeries
        sbcTaxes
        stocks
        Fault
      ].freeze

      # Fields that may carry an error message inside an envelope.
      ERROR_FIELDS = %w[errorText errorTextError].freeze

      # A request value object built by {.build_request} and sent by an
      # adapter.
      #
      # @!attribute [r] http_method HTTP method ("GET", "POST", ...).
      # @!attribute [r] url        Full URL (without query string).
      # @!attribute [r] headers    Hash of HTTP headers.
      # @!attribute [r] query      Hash of query parameters (may be nil).
      # @!attribute [r] body       Serialized request body (may be nil).
      Request = Struct.new(:http_method, :url, :headers, :query, :body, keyword_init: true)

      # Build the +Authorization: Basic ...+ header value for +username:token+.
      def self.build_auth_header(username, token)
        "Basic #{Base64.strict_encode64("#{username}:#{token}")}"
      end

      # Alias kept for parity with the Python SDK.
      def self.build_auth(username, token)
        build_auth_header(username, token)
      end

      # Construct a {Request} with SmartBill default headers.
      def self.build_request(method:, base_url:, path:, params: nil, json_body: nil,
                             accept: "application/json", content_type: "application/json",
                             auth_header: nil)
        url = path.start_with?("http") ? path : "#{base_url.chomp("/")}/#{path.delete_prefix("/")}"
        headers = { "Accept" => accept, "Content-Type" => content_type }
        headers["Authorization"] = auth_header if auth_header
        body = json_body ? JSON.generate(json_body) : nil
        Request.new(http_method: method.upcase, url: url, headers: headers, query: params, body: body)
      end

      # Unwrap the SmartBill response envelope and return its inner object.
      #
      # If the payload is a Hash whose only key is one of the known envelope
      # keys, the value under that key is returned. Otherwise the payload is
      # returned unchanged.
      def self.parse_envelope(payload)
        return payload unless payload.is_a?(Hash)

        if payload.size == 1
          key, value = payload.first
          return value if ENVELOPE_KEYS.include?(key)
        end
        # Some envelopes nest under a known key with sibling fields.
        ENVELOPE_KEYS.each do |key|
          next unless payload.key?(key)

          inner = payload[key]
          return inner if inner.is_a?(Hash)
        end
        payload
      end

      # Extract +(error_text, message)+ from an envelope.
      def self.extract_error(envelope)
        return ["", nil] unless envelope.is_a?(Hash)

        error_text = ""
        ERROR_FIELDS.each do |field|
          value = envelope[field]
          next unless value.is_a?(String) && !value.strip.empty?

          error_text = value
          break
        end
        message = envelope["message"]
        message = nil unless message.is_a?(String)
        [error_text, message]
      end

      # Validate a {Response} and return its parsed payload.
      #
      # Raises the appropriate {Error} subclass for auth / rate-limit / API
      # errors. When +binary+ is true, the raw body String is returned
      # (used for PDF endpoints).
      def self.handle_response(response, binary: false)
        status = response.status
        raise auth_error(response) if status == 401
        raise rate_limit_error if status == 403

        return response.body if binary && (200..299).cover?(status)
        return handle_success(response, status, binary: binary) if (200..299).cover?(status)

        raise api_error_from(response, status)
      end

      def self.auth_error(response)
        AuthError.new(
          "Authentication failed (401). Check username/token and company CIF. " \
          "Body: #{(response.body || "")[0, 200]}"
        )
      end

      def self.rate_limit_error
        RateLimitError.new(
          "Access blocked (403): rate limit exceeded. " \
          "SmartBill blocks access for 10 minutes after >30 calls/10s."
        )
      end

      def self.handle_success(response, status, binary:)
        content_type = response.content_type.to_s
        if content_type.include?("application/octet-stream") || response.body.nil? || response.body.empty?
          return binary ? response.body : nil
        end

        payload = begin
          JSON.parse(response.body)
        rescue JSON::ParserError => e
          raise TransportError, "Failed to decode JSON response: #{e.message}"
        end
        envelope = parse_envelope(payload)
        error_text, message = extract_error(envelope)
        raise APIError.new(error_text: error_text, message: message, status_code: status) unless error_text.empty?

        envelope
      end

      def self.api_error_from(response, status)
        error_text = ""
        message = nil
        payload = begin
          JSON.parse(response.body || "")
        rescue JSON::ParserError
          nil
        end
        if payload
          envelope = parse_envelope(payload)
          error_text, message = extract_error(envelope)
        else
          error_text = (response.body || "")[0, 300]
        end
        APIError.new(error_text: error_text, message: message, status_code: status)
      end

      private_class_method :auth_error, :rate_limit_error, :handle_success, :api_error_from

      # Simple token-bucket limiter: +max_calls+ per +window_seconds+.
      #
      # Optionally enabled by clients to preempt the server's 403.
      class RateLimiter
        attr_reader :max_calls, :window_seconds

        def initialize(max_calls: 30, window_seconds: 10.0)
          @max_calls = max_calls
          @window_seconds = window_seconds
          @timestamps = []
          @blocked_until = 0.0
        end

        # Raise {RateLimitError} if calling now would exceed the limit.
        def acquire
          now = Process.clock_gettime(Process::CLOCK_MONOTONIC)
          if now < @blocked_until
            wait = @blocked_until - now
            raise RateLimitError, format("Client-side rate limit: would block for %.1fs.", wait)
          end
          prune(now)
          if @timestamps.size >= @max_calls
            @blocked_until = @timestamps.first + @window_seconds
            wait = @blocked_until - now
            raise RateLimitError, format("Client-side rate limit exceeded: would block for %.1fs.", wait)
          end
          @timestamps << now
        end

        # Record a server-side 403 so the limiter backs off for 10 minutes.
        def notify_403
          @blocked_until = Process.clock_gettime(Process::CLOCK_MONOTONIC) + 600.0
        end

        private

        def prune(now)
          cutoff = now - @window_seconds
          @timestamps.select! { |t| t >= cutoff }
        end
      end
    end
  end
end
