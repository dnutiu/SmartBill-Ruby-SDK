# frozen_string_literal: true

module Smartbill
  module Sdk
    # A simple HTTP response value object returned by adapters.
    #
    # @!attribute [r] status  HTTP status code (Integer).
    # @!attribute [r] body    Raw response body (String, possibly binary).
    # @!attribute [r] content_type  Value of the +Content-Type+ header.
    Response = Struct.new(:status, :body, :content_type, keyword_init: true)
  end
end
