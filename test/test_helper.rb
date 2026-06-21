# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "smartbill/sdk"

require "minitest/autorun"
require "webmock/minitest"
require "base64"

# Shared constants & helpers for the test suite.
module SmartbillTest
  BASE = "https://ws.smartbill.ro/SBORO/api/"
  USERNAME = "user@example.com"
  TOKEN = "tok123"

  module_function

  def basic_auth_header
    "Basic #{Base64.strict_encode64("#{USERNAME}:#{TOKEN}")}"
  end

  def make_client(**)
    Smartbill::Sdk::Client.new(username: USERNAME, token: TOKEN, base_url: BASE, **)
  end

  # Build a SmartBill-style response envelope.
  def envelope(key, **fields)
    { key => fields }
  end

  # The most recent request recorded by WebMock.
  def last_request
    WebMock::RequestRegistry.instance.requested_signatures.hash.keys.last
  end

  # Parsed query params (Hash) of a recorded request.
  def query_of(req)
    params = {}
    URI.decode_www_form(req.uri.query.to_s).each do |key, value|
      params[key] = value
    end
    params
  end

  # Look up a header case-insensitively.
  def header(req, name)
    key = req.headers.keys.find { |k| k.downcase == name.downcase }
    req.headers[key]
  end

  def assert_auth(req)
    assert_equal basic_auth_header, header(req, "Authorization")
  end

  def assert_json_headers(req)
    assert_equal "application/json", header(req, "Accept")
    assert_equal "application/json", header(req, "Content-Type")
  end
end
