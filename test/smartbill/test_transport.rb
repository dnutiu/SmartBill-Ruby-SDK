# frozen_string_literal: true

require "test_helper"

# Tests for the transport layer, auth handling and client setup.
module Smartbill
  class TestTransport < Minitest::Test
    include SmartbillTest

    def test_default_base_url
      assert_equal "https://ws.smartbill.ro/SBORO/api/", Smartbill::Sdk::Transport::DEFAULT_BASE_URL
      assert_equal "https://ws.smartbill.ro/SBORO/api/", Smartbill::Sdk::DEFAULT_BASE_URL
    end

    def test_build_auth_sets_basic_header
      header = Smartbill::Sdk::Transport.build_auth(USERNAME, TOKEN)
      assert_equal basic_auth_header, header
      assert header.start_with?("Basic ")
    end

    def test_build_request_json_headers_and_url
      req = Smartbill::Sdk::Transport.build_request(
        method: "post", base_url: BASE, path: "invoice",
        json_body: { invoice: {} }, auth_header: basic_auth_header
      )
      assert_equal "https://ws.smartbill.ro/SBORO/api/invoice", req.url
      assert_equal "POST", req.http_method
      assert_equal "application/json", req.headers["Accept"]
      assert_equal "application/json", req.headers["Content-Type"]
      assert_equal basic_auth_header, req.headers["Authorization"]
      assert_equal %({"invoice":{}}), req.body
    end

    def test_build_request_params
      req = Smartbill::Sdk::Transport.build_request(
        method: "get", base_url: BASE, path: "tax",
        params: { "cif" => "RO123" }, auth_header: basic_auth_header
      )
      assert_equal({ "cif" => "RO123" }, req.query)
    end

    def test_parse_envelope_known_keys
      assert_equal({ "number" => "1" },
                   Smartbill::Sdk::Transport.parse_envelope({ "sbcResponse" => { "number" => "1" } }))
      assert_equal({ "number" => "1" }, Smartbill::Sdk::Transport.parse_envelope({ "Response" => { "number" => "1" } }))
      assert_equal({ "taxes" => [] }, Smartbill::Sdk::Transport.parse_envelope({ "sbcTaxes" => { "taxes" => [] } }))
      assert_equal({ "list" => [] }, Smartbill::Sdk::Transport.parse_envelope({ "stocks" => { "list" => [] } }))
    end

    def test_parse_envelope_passthrough
      assert_equal({ "number" => "1", "series" => "FCT" },
                   Smartbill::Sdk::Transport.parse_envelope({ "number" => "1", "series" => "FCT" }))
      assert_equal [1, 2, 3], Smartbill::Sdk::Transport.parse_envelope([1, 2, 3])
    end

    def make_response(status:, json: nil, body: nil, content_type: nil)
      body_str = body
      body_str = JSON.generate(json) if json
      Smartbill::Sdk::Response.new(status: status, body: body_str, content_type: content_type)
    end

    def test_handle_response_401
      assert_raises(Smartbill::Sdk::AuthError) do
        Smartbill::Sdk::Transport.handle_response(make_response(status: 401, body: "nope"))
      end
    end

    def test_handle_response_403
      assert_raises(Smartbill::Sdk::RateLimitError) do
        Smartbill::Sdk::Transport.handle_response(make_response(status: 403, body: "blocked"))
      end
    end

    def test_handle_response_error_envelope_raises
      resp = make_response(status: 200, json: { "sbcResponse" => { "errorText" => "bad" } })
      err = assert_raises(Smartbill::Sdk::APIError) { Smartbill::Sdk::Transport.handle_response(resp) }
      assert_equal "bad", err.error_text
      assert_equal 200, err.status_code
    end

    def test_handle_response_success_returns_envelope
      resp = make_response(status: 200, json: { "sbcResponse" => { "number" => "0010", "series" => "FCT" } },
                           content_type: "application/json")
      assert_equal({ "number" => "0010", "series" => "FCT" }, Smartbill::Sdk::Transport.handle_response(resp))
    end

    def test_handle_response_binary
      resp = make_response(status: 200, body: "%PDF-1.4 ...", content_type: "application/octet-stream")
      assert_equal "%PDF-1.4 ...", Smartbill::Sdk::Transport.handle_response(resp, binary: true)
    end

    def test_handle_response_non_2xx_with_body
      resp = make_response(status: 400, json: { "Fault" => { "errorText" => "Client invalid!" } })
      err = assert_raises(Smartbill::Sdk::APIError) { Smartbill::Sdk::Transport.handle_response(resp) }
      assert_includes err.error_text, "Client invalid"
      assert_equal 400, err.status_code
    end

    def test_client_sets_services_and_auth
      c = make_client
      refute_nil c.invoices
      assert_same c.taxes, c.series
      assert c.auth_header.start_with?("Basic ")
      c.close
    end
  end
end
