# frozen_string_literal: true

require "net/http"
require "uri"

module Smartbill
  module Sdk
    # Default HTTP adapter backed by stdlib +Net::HTTP+.
    #
    # The SDK talks to the adapter through a single method, {#call}, which
    # receives a {Transport::Request} and returns a {Response}. This keeps
    # the transport logic decoupled from the HTTP library and makes it
    # trivial to swap in another adapter (or stub one in tests).
    class NetHttpAdapter
      METHOD_CLASSES = {
        "GET" => Net::HTTP::Get,
        "POST" => Net::HTTP::Post,
        "PUT" => Net::HTTP::Put,
        "DELETE" => Net::HTTP::Delete,
        "PATCH" => Net::HTTP::Patch
      }.freeze

      def initialize(timeout: 30)
        @timeout = timeout
      end

      def call(req)
        uri = build_uri(req)
        request = build_request(req, uri)
        response = perform(uri, request)
        Response.new(status: response.code.to_i, body: response.body,
                     content_type: response["content-type"])
      rescue ArgumentError, Net::HTTPError => e
        raise TransportError, "Transport error: #{e.message}"
      end

      private

      def build_uri(req)
        uri = URI(req.url)
        uri.query = URI.encode_www_form(req.query) if req.query && !req.query.empty?
        uri
      end

      def build_request(req, uri)
        klass = METHOD_CLASSES[req.http_method] ||
                raise(TransportError, "Unsupported HTTP method: #{req.http_method}")
        request = klass.new(uri.request_uri)
        req.headers.each { |key, value| request[key] = value }
        request.body = req.body if req.body
        request
      end

      def perform(uri, request)
        Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https",
                                            read_timeout: @timeout, open_timeout: @timeout) do |http|
          http.request(request)
        end
      end
    end
  end
end
