# frozen_string_literal: true

require "test_helper"
require "json"

# Endpoint tests for EstimatesService via WebMock.
module Smartbill
  class TestEstimates < Minitest::Test
    include SmartbillTest

    Models = Smartbill::Sdk::Models

    def setup
      WebMock.reset!
    end

    def test_estimate_create_sync
      stub = stub_request(:post, "#{BASE}estimate")
             .to_return(status: 200, body: JSON.generate(envelope("sbcResponse", number: "0001", series: "PFC")),
                        headers: { "Content-Type" => "application/json" })
      c = make_client
      est = Models::Estimate.new(company_vat_code: "RO1", client: Models::Client.new(name: "X"),
                                 series_name: "PFC",
                                 products: [Models::Product.new(name: "p", measuring_unit_name: "buc",
                                                                currency: "RON", quantity: 1, price: 10)])
      r = c.estimates.create(est)
      assert_equal "PFC", r.series
      assert_equal "0001", r.number
      payload = JSON.parse(last_request.body)
      assert_equal "RO1", payload["companyVatCode"]
      assert_auth(last_request)
      assert_requested stub
      c.close
    end

    def test_estimate_delete_sync
      stub = stub_request(:delete, "#{BASE}estimate")
             .with(query: { "cif" => "RO1", "seriesName" => "PFC", "number" => "0001" })
             .to_return(status: 200, body: JSON.generate(envelope("sbcResponse", message: "ok")),
                        headers: { "Content-Type" => "application/json" })
      c = make_client
      c.estimates.delete("RO1", "PFC", "0001")
      assert_equal "PFC", query_of(last_request)["seriesName"]
      assert_requested stub
      c.close
    end

    def test_estimate_cancel_sync
      stub_request(:put, "#{BASE}estimate/cancel")
        .with(query: { "cif" => "RO1", "seriesName" => "PFC", "number" => "0001" })
        .to_return(status: 200, body: JSON.generate(envelope("sbcResponse", message: "ok")),
                   headers: { "Content-Type" => "application/json" })
      c = make_client
      c.estimates.cancel("RO1", "PFC", "0001")
      assert_equal "0001", query_of(last_request)["number"]
      c.close
    end

    def test_estimate_restore_sync
      stub_request(:put, "#{BASE}estimate/restore")
        .with(query: { "cif" => "RO1", "seriesName" => "PFC", "number" => "0001" })
        .to_return(status: 200, body: JSON.generate(envelope("sbcResponse", message: "ok")),
                   headers: { "Content-Type" => "application/json" })
      c = make_client
      c.estimates.restore("RO1", "PFC", "0001")
      assert_equal "restore", last_request.uri.path.split("/").last
      c.close
    end

    def test_estimate_pdf_sync
      stub_request(:get, "#{BASE}estimate/pdf")
        .with(query: { "cif" => "RO1", "seriesName" => "PFC", "number" => "0001" })
        .to_return(status: 200, body: "%PDF-1.4 pf", headers: { "Content-Type" => "application/octet-stream" })
      c = make_client
      data = c.estimates.pdf("RO1", "PFC", "0001")
      assert_equal "%PDF-1.4 pf", data
      assert_equal "application/octet-stream", header(last_request, "Accept")
      c.close
    end

    def test_estimate_invoices_status_sync
      stub_request(:get, "#{BASE}estimate/invoices")
        .with(query: { "cif" => "RO1", "seriesName" => "PFC", "number" => "0001" })
        .to_return(status: 200,
                   body: JSON.generate(envelope("sbcResponse",
                                                areInvoicesCreated: true,
                                                invoices: [{ "series" => "FCT", "number" => "0028" },
                                                           { "series" => "FCT", "number" => "0036" }])),
                   headers: { "Content-Type" => "application/json" })
      c = make_client
      r = c.estimates.invoices_status("RO1", "PFC", "0001")
      assert r.are_invoices_created
      assert_equal 2, r.invoices.size
      assert_equal "FCT", r.invoices.first.series_name
      c.close
    end
  end
end
