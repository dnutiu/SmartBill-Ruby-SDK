# frozen_string_literal: true

require "test_helper"
require "json"

# Endpoint tests for InvoicesService via WebMock.
module Smartbill
  class TestInvoices < Minitest::Test
    include SmartbillTest

    Models = Smartbill::Sdk::Models

    def setup
      WebMock.reset!
    end

    # --- create ---
    def test_invoice_create_sync
      stub = stub_request(:post, "#{BASE}invoice")
             .to_return(status: 200, body: JSON.generate(envelope("sbcResponse", errorText: "", message: "", number: "0040", series: "FCT")),
                        headers: { "Content-Type" => "application/json" })
      c = make_client
      inv = Models::Invoice.new(company_vat_code: "RO1", client: Models::Client.new(name: "X"),
                                series_name: "FCT",
                                products: [Models::Product.new(name: "p", measuring_unit_name: "buc",
                                                               currency: "RON", quantity: 1, price: 10)])
      resp = c.invoices.create(inv)
      assert_equal "0040", resp.number
      assert_equal "FCT", resp.series

      req = last_request
      assert_auth(req)
      assert_json_headers(req)
      payload = JSON.parse(req.body)
      assert_equal "RO1", payload["companyVatCode"]
      assert_equal "X", payload["client"]["name"]
      assert_requested stub
      c.close
    end

    # --- delete ---
    def test_invoice_delete_sync
      stub = stub_request(:delete, "#{BASE}invoice")
             .with(query: { "cif" => "RO1", "seriesName" => "FCT", "number" => "0040" })
             .to_return(status: 200, body: JSON.generate(envelope("sbcResponse", message: "Factura cu seria si numarul FCT0040 a fost stearsa cu succes.")),
                        headers: { "Content-Type" => "application/json" })
      c = make_client
      resp = c.invoices.delete("RO1", "FCT", "0040")
      assert_includes (resp.message || ""), "stearsa"
      req = last_request
      assert_equal "DELETE", req.method.to_s.upcase
      assert_equal({ "cif" => "RO1", "seriesName" => "FCT", "number" => "0040" }, query_of(req))
      assert_requested stub
      c.close
    end

    # --- reverse ---
    def test_invoice_reverse_sync
      stub_request(:post, "#{BASE}invoice/reverse")
        .to_return(status: 200, body: JSON.generate(envelope("sbcResponse", number: "0986", series: "FFF",
                                                                            documentUrl: "https://cloud.smartbill.ro/x",
                                                                            documentId: "274119",
                                                                            documentViewUrl: "https://cloud.smartbill.ro/v")),
                   headers: { "Content-Type" => "application/json" })
      c = make_client
      r = c.invoices.reverse(Models::StornoRequest.new(company_vat_code: "RO1", series_name: "FFF", number: "0985"))
      assert_equal "274119", r.document_id
      assert r.document_url.end_with?("/x")
      payload = JSON.parse(last_request.body)
      assert_equal({ "companyVatCode" => "RO1", "seriesName" => "FFF", "number" => "0985" }, payload)
      c.close
    end

    # --- cancel ---
    def test_invoice_cancel_sync
      stub_request(:put, "#{BASE}invoice/cancel")
        .with(query: { "cif" => "RO1", "seriesName" => "FCT", "number" => "0040" })
        .to_return(status: 200, body: JSON.generate(envelope("sbcResponse", message: "Factura cu seria si numarul FCT0040 a fost anulata cu succes.")),
                   headers: { "Content-Type" => "application/json" })
      c = make_client
      r = c.invoices.cancel("RO1", "FCT", "0040")
      assert_includes (r.message || ""), "anulata"
      assert_equal "FCT", query_of(last_request)["seriesName"]
      c.close
    end

    # --- restore ---
    def test_invoice_restore_sync
      stub_request(:put, "#{BASE}invoice/restore")
        .with(query: { "cif" => "RO1", "seriesName" => "FCT", "number" => "0040" })
        .to_return(status: 200, body: JSON.generate(envelope("sbcResponse", message: "ok")),
                   headers: { "Content-Type" => "application/json" })
      c = make_client
      c.invoices.restore("RO1", "FCT", "0040")
      assert_equal "0040", query_of(last_request)["number"]
      c.close
    end

    # --- payment status ---
    def test_invoice_payment_status_sync
      stub_request(:get, "#{BASE}invoice/paymentstatus")
        .with(query: { "cif" => "RO1", "seriesName" => "FCT", "number" => "0040" })
        .to_return(status: 200, body: JSON.generate(envelope("sbcInvoicePaymentStatusResponse",
                                                             invoiceTotalAmount: 100, paidAmount: 62, unpaidAmount: 38)),
                   headers: { "Content-Type" => "application/json" })
      c = make_client
      r = c.invoices.payment_status("RO1", "FCT", "0040")
      assert_equal 100, r.invoice_total_amount
      assert_equal 62, r.paid_amount
      assert_equal 38, r.unpaid_amount
      c.close
    end

    # --- pdf ---
    def test_invoice_pdf_sync
      stub_request(:get, "#{BASE}invoice/pdf")
        .with(query: { "cif" => "RO1", "seriesName" => "FCT", "number" => "0040" })
        .to_return(status: 200, body: "%PDF-1.4 fake", headers: { "Content-Type" => "application/octet-stream" })
      c = make_client
      data = c.invoices.pdf("RO1", "FCT", "0040")
      assert data.start_with?("%PDF")
      assert_equal "application/octet-stream", header(last_request, "Accept")
      c.close
    end

    # --- error handling ---
    def test_invoice_create_error_raises
      stub_request(:post, "#{BASE}invoice")
        .to_return(status: 200, body: JSON.generate(envelope("sbcResponse", errorText: "Client invalid!")),
                   headers: { "Content-Type" => "application/json" })
      c = make_client
      err = assert_raises(Smartbill::Sdk::APIError) do
        c.invoices.create(Models::Invoice.new(company_vat_code: "RO1", client: Models::Client.new(name: "x")))
      end
      assert_includes err.error_text, "Client invalid"
      c.close
    end

    def test_invoice_create_400_raises
      stub_request(:post, "#{BASE}invoice")
        .to_return(status: 400, body: JSON.generate({ "Fault" => { "errorText" => "Date gresite" } }),
                   headers: { "Content-Type" => "application/json" })
      c = make_client
      err = assert_raises(Smartbill::Sdk::APIError) do
        c.invoices.create(Models::Invoice.new(company_vat_code: "RO1", client: Models::Client.new(name: "x")))
      end
      assert_equal 400, err.status_code
      c.close
    end
  end
end
