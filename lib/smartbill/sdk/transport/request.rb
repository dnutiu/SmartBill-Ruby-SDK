# frozen_string_literal: true

module Smartbill
  module Sdk
    module Transport
      # A request value object built by {Transport.build_request} and sent
      # by an adapter.
      #
      # @!attribute [r] http_method HTTP method ("GET", "POST", ...).
      # @!attribute [r] url        Full URL (without query string).
      # @!attribute [r] headers    Hash of HTTP headers.
      # @!attribute [r] query      Hash of query parameters (may be nil).
      # @!attribute [r] body       Serialized request body (may be nil).
      Request = Struct.new(:http_method, :url, :headers, :query, :body, keyword_init: true)
    end
  end
end
