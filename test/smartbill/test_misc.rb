# frozen_string_literal: true

require "test_helper"
require "json"

# Endpoint tests for email, taxes, series and stocks via WebMock.
module Smartbill
  class TestMisc < Minitest::Test
    include SmartbillTest

    Models = Smartbill::Sdk::Models

    def setup
      WebMock.reset!
    end

    # --- email ---
    def test_email_send_sync
      stub = stub_request(:post, "#{BASE}document/send")
             .to_return(status: 200,
                        body: JSON.generate({ "Response" => { "status" => { "code" => "0",
                                                                            "message" => "Documentul a fost trimis cu succes." } } }),
                        headers: { "Content-Type" => "application/json" })
      c = make_client
      e = Models::EmailDocument.new(company_vat_code: "RO1", series_name: "FCT", number: "0040",
                                    type: Models::DocumentType::INVOICE, to: "office@x.ro",
                                    subject: "subj", body_text: "body")
      r = c.email.send(e)
      assert_equal "0", r.status.code
      assert_includes r.status.message, "trimis"
      payload = JSON.parse(last_request.body)
      assert_equal "RO1", payload["companyVatCode"]
      assert_equal "factura", payload["type"]
      assert_requested stub
      c.close
    end

    def test_email_send_integer_status_code
      stub_request(:post, "#{BASE}document/send")
        .to_return(status: 200, body: JSON.generate({ "Response" => { "status" => { "code" => 0, "message" => "ok" } } }),
                   headers: { "Content-Type" => "application/json" })
      c = make_client
      e = Models::EmailDocument.new(company_vat_code: "RO1", series_name: "FCT", number: "0040",
                                    type: "proforma")
      r = c.email.send(e)
      assert_equal 0, r.status.code
      c.close
    end

    # --- taxes ---
    def test_taxes_sync
      stub = stub_request(:get, "#{BASE}tax")
             .with(query: { "cif" => "RO1" })
             .to_return(status: 200,
                        body: JSON.generate(envelope("sbcTaxes", taxes: [{ "name" => "Normala", "percentage" => 19 },
                                                                         { "name" => "Redusa", "percentage" => 9 }])),
                        headers: { "Content-Type" => "application/json" })
      c = make_client
      r = c.taxes.taxes("RO1")
      assert_equal 2, r.taxes.size
      assert_equal "Normala", r.taxes.first.name
      assert_equal 19, r.taxes.first.percentage
      assert_equal "RO1", query_of(last_request)["cif"]
      assert_requested stub
      c.close
    end

    def test_taxes_empty
      stub_request(:get, /#{Regexp.escape(BASE)}tax/)
        .with(query: { "cif" => "RO1" })
        .to_return(status: 200, body: JSON.generate(envelope("sbcTaxes", taxes: [])),
                   headers: { "Content-Type" => "application/json" })
      c = make_client
      r = c.taxes.taxes("RO1")
      assert_equal [], r.taxes
      c.close
    end

    # --- series ---
    def test_series_sync_with_type
      stub_request(:get, "#{BASE}series")
        .with(query: { "cif" => "RO1", "type" => "f" })
        .to_return(status: 200,
                   body: JSON.generate(envelope("sbcSeries", list: [{ "name" => "FCT", "nextNumber" => "0117", "type" => "f" },
                                                                    { "name" => "CHT", "nextNumber" => 13,
                                                                      "type" => "c" }])),
                   headers: { "Content-Type" => "application/json" })
      c = make_client
      r = c.series.series("RO1", type: "f")
      assert_equal 2, r.list.size
      assert_equal "FCT", r.list.first.name
      assert_equal "0117", r.list.first.next_number
      assert_equal 13, r.list[1].next_number
      p = query_of(last_request)
      assert_equal "RO1", p["cif"]
      assert_equal "f", p["type"]
      c.close
    end

    def test_series_sync_without_type
      stub_request(:get, "#{BASE}series")
        .with(query: { "cif" => "RO1" })
        .to_return(status: 200, body: JSON.generate(envelope("sbcSeries", list: [])),
                   headers: { "Content-Type" => "application/json" })
      c = make_client
      c.series.series("RO1")
      refute query_of(last_request).key?("type")
      c.close
    end

    # --- stocks ---
    def test_stocks_sync
      stub_request(:get, "#{BASE}stocks")
        .with(query: { "cif" => "RO1", "date" => "2021-03-01", "warehouseName" => "Depozit" })
        .to_return(status: 200,
                   body: JSON.generate({ "stocks" => {
                                         "errorText" => "", "message" => "", "number" => "", "series" => "",
                                         "list" => [
                                           { "products" => [{ "measuringUnit" => "buc", "productCode" => "IT001",
                                                              "productName" => "Revista IT", "quantity" => 100 }],
                                             "warehouse" => { "warehouseName" => "GestiuneMagazin1",
                                                              "warehouseType" => "en detail" } }
                                         ]
                                       } }),
                   headers: { "Content-Type" => "application/json" })
      c = make_client
      r = c.stocks.get("RO1", "2021-03-01", warehouse_name: "Depozit")
      assert_equal 1, r.list.size
      assert_equal "Revista IT", r.list.first.products.first.product_name
      assert_equal "en detail", r.list.first.warehouse.warehouse_type
      p = query_of(last_request)
      assert_equal "RO1", p["cif"]
      assert_equal "2021-03-01", p["date"]
      assert_equal "Depozit", p["warehouseName"]
      c.close
    end

    def test_stocks_with_product_filters
      stub_request(:get, "#{BASE}stocks")
        .with(query: { "cif" => "RO1", "date" => "2021-03-01", "productName" => "X", "productCode" => "Y" })
        .to_return(status: 200, body: JSON.generate({ "stocks" => { "list" => [] } }),
                   headers: { "Content-Type" => "application/json" })
      c = make_client
      r = c.stocks.get("RO1", "2021-03-01", product_name: "X", product_code: "Y")
      assert_equal [], r.list
      c.close
    end

    def test_stocks_error_envelope_raises
      stub_request(:get, /#{Regexp.escape(BASE)}stocks/)
        .with(query: { "cif" => "RO1", "date" => "2021-03-01" })
        .to_return(status: 200,
                   body: JSON.generate({ "stocks" => { "errorText" => "Data la care vreti sa aflati valoarea stocului trebuie specificata!" } }),
                   headers: { "Content-Type" => "application/json" })
      c = make_client
      err = assert_raises(Smartbill::Sdk::APIError) { c.stocks.get("RO1", "2021-03-01") }
      assert_includes err.error_text, "Data"
      c.close
    end
  end
end
